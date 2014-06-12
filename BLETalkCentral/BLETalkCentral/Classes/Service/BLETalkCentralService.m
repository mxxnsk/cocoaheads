//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "BLETalkCentralService.h"
#import "BLEDevice.h"
#import "AppContext.h"


@implementation BLETalkCentralService {

}

-(void) startService {
    AppCTX.devices = [[NSMutableArray alloc] initWithCapacity:10];
    if(!self.manager) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }

    self.transmitCharUUID = [CBUUID UUIDWithString:CHAR_TX];
    self.serviceUUID = [CBUUID UUIDWithString:SERVICE_ID];

    [self startScan];
}


@end