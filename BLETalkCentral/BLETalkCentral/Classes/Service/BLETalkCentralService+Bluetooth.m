//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import "BLETalkCentralService.h"
#import "AppContext.h"


@implementation BLETalkCentralService (Bluetooth)


-(bool) write: (NSData*) data {
    bool result = NO;
    for(BLEDevice * device in AppCTX.devices) {
        result = result || [self write:device data:data];
    }
    return result;
}

-(bool) write:(BLEDevice *)device data:(NSData *)data {
    NSLog(@"Write to device: , %@", device);
    device.dataToSend = data;
    device.currentDataOffset = 0;
    device.extendedState = SEND_START;

    CBService * service = [self getService:device.peripheral];
    CBCharacteristic * ch = [self getCharacteristicByUUID:self.transmitCharUUID service:service];
    if(!ch) {
        NSLog(@"ERROR: write error: ch is nil");
        [self disconnectDevice:device];
        return false;
    }

    [device.peripheral
            writeValue:[@"START" dataUsingEncoding:NSASCIIStringEncoding]
     forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
    return true;
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValForChar");

    BLEDevice * device = [self getDiscoveredDevice:peripheral];
    if(error) {
        NSLog(@"Data send failed to: %@", device);
        device.extendedState = SEND_IDLE;
        device.dataToSend = nil;
        device.currentDataOffset = 0;
        return;
    }
    if(device.extendedState == SEND_START) {
        device.extendedState = SEND_DATA;
    }
    if(device.extendedState == SEND_DATA) {
        if ( device.currentDataOffset <  device.dataToSend.length) {

            NSLog(@"Send data, current offset is: %d", device.currentDataOffset);
            int dataLeft = device.dataToSend.length - device.currentDataOffset;
            int size = dataLeft > 19 ? 19 : dataLeft;

            NSData * data = [device.dataToSend subdataWithRange:NSMakeRange(device.currentDataOffset, size)];

            NSLog(@"send data delegate %d", device.currentDataOffset);

            [device.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            device.currentDataOffset+=19;
            return;
        }
        device.extendedState = SEND_END;
    }
    if(device.extendedState == SEND_END) {
        [device.peripheral
                writeValue:[@"END" dataUsingEncoding:NSASCIIStringEncoding]
         forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        device.extendedState = SEND_IDLE;
        device.dataToSend = nil;
        device.currentDataOffset = 0;
        return;

    }
}


-(BLEDevice *) getDiscoveredDevice:(CBPeripheral *)p {
    for(BLEDevice * device in AppCTX.devices) {
        if(device.peripheral == p) {
            return device;
        }
    }
    return nil;
}


-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([s.UUID isEqual:UUID]){
            return s;
        }
    }
    return nil;
}

-(CBService *) getService:(CBPeripheral *)p {
    CBUUID * serviceID = [CBUUID UUIDWithString:[SERVICE_ID uppercaseString]];
    CBService *  service = [self findServiceFromUUID:serviceID p:p];
    return service;
}

-(CBCharacteristic *)getCharacteristicByUUID:(CBUUID *)UUID service:(CBService*)service {
    NSLog(@"Looking for: %@", UUID);
    for(CBCharacteristic * ch in service.characteristics) {
        NSLog(@"----- Char: %@", ch.UUID);
        if([UUID isEqual:ch.UUID]) {
            NSLog(@"Found! : %@", ch.UUID);
            return ch;
        }
    }
    return nil;
}

- (void)startScan {
    NSLog(@"startScan");
    [self.manager stopScan];

    NSArray	* uuidArray = nil;//@[[CBUUID UUIDWithString:SERVICE_ID]];
    NSDictionary * options = @{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO] };
    [self.manager scanForPeripheralsWithServices:uuidArray options:options];
}


- (void)stopScan {
    [self.manager stopScan];
}



-(void) connectDevice: (BLEDevice *) device {
    if(device.peripheral.state == CBPeripheralStateConnected || device.peripheral.state == CBPeripheralStateConnecting) {
        NSLog(@"Already connected peripheral, returning %@", device.peripheral);
        return;
    }

    device.extendedState = csConnecting;

    [self.manager connectPeripheral:device.peripheral
                            options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : [NSNumber numberWithBool:YES]}];

}

-(void) disconnectDevice: (BLEDevice *) device {
    if(!device.peripheral.state == CBPeripheralStateConnected) {
        NSLog(@"@ is not connected", device);
        return;
    }
    [self.manager cancelPeripheralConnection:device.peripheral];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"BLE module is power ON now");
    } else {
        NSLog(@"BLE module state changed:%d", central.state);
    }
}





- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral %@", advertisementData);


    // Note: checking adv. params for services and device name you can assume wich state peripheral app is running in

//    NSArray * services = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
//    BOOL serviceFound = NO;
//    if(services) {
//        for(CBUUID * serviceUUID in services) {
//            if([serviceUUID isEqual:self.serviceUUID]) {
//                serviceFound = YES;
//
//            }
//        }
//    }
//    if(!serviceFound) {
//        NSLog(@"Service not found");
//        return;
//    }


    BLEDevice * device = [self getDiscoveredDevice:peripheral];

    if(!device) {
        device = [[BLEDevice alloc] init];
        device.connectStep = csDiscovered;
        device.peripheral = peripheral;
        device.peripheral.delegate  = self;
        device.rssi = RSSI;
        NSString * name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
        device.name = name ? name : (device.name ? device.name : peripheral.name);
        [AppCTX.devices addObject:device];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
    }  else {
        device.rssi = RSSI;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
    }
//    if(device.connectStep == csDiscovered) {
//        [self connectDevice:device];
//    }
}



- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    BLEDevice * device = [self getDiscoveredDevice:peripheral];
    device.connectStep = csConnected;
    NSLog(@"connected: %@", device);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_ID]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    BLEDevice * device = [self getDiscoveredDevice:peripheral];
    device.connectStep = csDiscovered;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    BLEDevice * device = [self getDiscoveredDevice:peripheral];
    device.connectStep = csService;
    NSLog(@"dicscovered services for: %@", device);
    if(error) {
        NSLog(@"STOP: Error discovering service: %@", error);
        // TODO PROBABLY DELAY THIS ACTION
        [self disconnectDevice:device];
        return;
    }


//    CBUUID * serviceID = [CBUUID UUIDWithString:[SERVICE_ID uppercaseString]];
    CBService *  service = [self findServiceFromUUID:self.serviceUUID p:peripheral];
    if(!service) {
        NSLog(@"STOP: POS Service is not found on the device:%@", peripheral);
        [self disconnectDevice:device];
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
    NSLog(@"now discover characteristics for: %@", device);
    [peripheral discoverCharacteristics:@[self.transmitCharUUID] forService:service];

}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    BLEDevice * device = [self getDiscoveredDevice:peripheral];

    NSLog(@"got characteristics: %@", device);
    if(error) {
        NSLog(@"STOP: didDiscoverCharacteristicsForService: %@ : %@", peripheral.name, error);
        [self disconnectDevice:device];
        return;
    }

    if(![service.UUID isEqual:self.serviceUUID]) {
        NSLog(@"Chars for wrong service: %@", service.UUID);
        return;
    }

    CBCharacteristic * ch = [self getCharacteristicByUUID:self.transmitCharUUID service:service];
    if(!ch) {
        NSLog(@"STOP: could not find transmit characteristic");
        [self disconnectDevice:device];
//        service.c
        return;
    }

    device.connectStep = csReady;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];
    [self stopScan];
}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}



- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"peripheralDidUpdateName %@", peripheral.name);
    BLEDevice * device = [self getDiscoveredDevice:peripheral];
    device.name = peripheral.name;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE" object:device];

}



- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {

}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {

}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {

}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {

}
@end