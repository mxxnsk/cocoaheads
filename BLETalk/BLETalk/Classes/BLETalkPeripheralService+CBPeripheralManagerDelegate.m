//
// Created by Maxim Ignatyev on 6/11/14.
//
//


#import "BLETalkPeripheralService.h"


@implementation BLETalkPeripheralService (CBPeripheralManagerDelegate)

//
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {


    // Check that BT is actually powered on
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Bluetooth is turned off, exiting..");
        return;
    }

    if(self.service) {
        [self resetAdvertisement];
        return;
    }

    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@BLE_SERVICE_UUID]
                                                                       primary:YES];
    self.characteristicReceive = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@BLE_RECEIVE_UUID]
                                                                    properties:CBCharacteristicPropertyWrite
                                                                         value:nil permissions:CBAttributePermissionsWriteEncryptionRequired];

    self.characteristicTransmit = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@BLE_TRANSMIT_UUID]
                                                                     properties:CBCharacteristicPropertyRead
                                                                          value:nil permissions:CBAttributePermissionsReadable];


    // Add the characteristic to the service
    transferService.characteristics = @[self.characteristicReceive/*, self.characteristicTransmit*/];


    self.service = transferService;

    self.advertisementData = @{
            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@BLE_SERVICE_UUID]],
            CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name };

    // And add service to the peripheral manager
    [self.peripheralManager addService:transferService];


    [self resetAdvertisement];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {

}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *req in requests){

        // Note: In case you have several writable characteristics check which characteristic was actually written by a central
        // if([req.characteristic isEqual:self.characteristicReceive])

        // Note: I'm not handling case with multiple centrals connected to a single peripheral, but in a real life there should be separate states for every central
        //NSMutableData * dataReceived  = [self dataReceivedForCentral: req.central];

        if([self.startSignal isEqual:req.value]) {
            self.dataReceived = [NSMutableData data];
        } else if([self.endSignal isEqual:req.value]) {


            NSString *actualString = [[NSString alloc] initWithData:self.dataReceived encoding:NSASCIIStringEncoding];
            NSLog(@"Okay, here what we have from a central: %@", actualString);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATEUI" object:actualString];
        } else {
            if(!self.dataReceived) {
                NSLog(@"Something went wrong: there were no start signal");
            } else {
                [self.dataReceived appendData:req.value];
            }
        }

        [peripheral respondToRequest:req withResult:CBATTErrorSuccess];
    }

}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    if(status == SEND_IDLE) {
        NSLog(@"idle delegate");
        return;
    }

    bool result;
    if(status == SEND_START) {
        NSLog(@"Try to send start phrase");
        bool result = [self.peripheralManager updateValue:self.startSignal forCharacteristic:self.characteristicTransmit onSubscribedCentrals:nil];  // Broadcast to all subscribed centrals
        if (!result) {
            NSLog(@"Failed to send start phrase, will retry");
            return;
        }
        currentOffset = 0;
        status = SEND_DATA;
    }
    if (status == SEND_DATA) {  // split data into chunks and send
        NSLog(@"Try to send data chunk");

        for (int i = currentOffset; i < self.dataToSend.length; i+=19) {
            currentOffset = i;
            int dataLeft = self.dataToSend.length - i;
            int size = dataLeft > 19 ? 19 : dataLeft;

            NSData *chunkToSend = [self.dataToSend subdataWithRange:NSMakeRange(i, size)];
            result = [self.peripheralManager updateValue:chunkToSend forCharacteristic:self.characteristicTransmit onSubscribedCentrals:nil];
            if (!result) {
                NSLog(@"Failed to send data chunk, will retry");
                return;
            }
        }
        status = SEND_END;
    }
    if (status == SEND_END) {
        NSLog(@"Try to send end phrase");
        result = [self.peripheralManager updateValue:self.endSignal forCharacteristic:self.characteristicTransmit onSubscribedCentrals:nil];

        if(!result) {
            NSLog(@"Failed to send end phrase, will retry");
            return;
        }
        status = SEND_IDLE;
        currentOffset = 0;
    }

}






@end