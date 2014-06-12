//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"


#define SERVICE_ID @"c290064f-1abf-42bd-b51c-64b3c3b719ab"

#define CHAR_TX    @"b2458c60-71fc-43c9-84c3-e6a5afcbf708"


@interface BLETalkCentralService : NSObject

@property (strong, nonatomic) CBCentralManager * manager;
@property (strong, nonatomic) CBUUID * transmitCharUUID;
@property (strong, nonatomic) CBUUID * serviceUUID;

-(void) startService;

- (void)disconnectDevice:(BLEDevice *)device;
@end


@interface BLETalkCentralService (Bluetooth)<CBCentralManagerDelegate, CBPeripheralDelegate>

-(BLEDevice *) getDiscoveredDevice: (CBPeripheral *) peripheral;
-(void) connectDevice: (BLEDevice *) device;
-(void) startScan;
-(void) stopScan;
-(bool) write: (NSData*) data;

@end

