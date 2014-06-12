//
// Created by Maxim Ignatyev on 6/11/14.
//
//


#import "BLETalkPeripheralService.h"


@implementation BLETalkPeripheralService {
}


+(BLETalkPeripheralService *) service {
    BLETalkPeripheralService * service = [[BLETalkPeripheralService alloc] init];
    return service;
}


-(id) init {
    if(self = [super init]) {


        NSDictionary * options = @{CBPeripheralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES], CBPeripheralManagerOptionRestoreIdentifierKey: @"cbPeripheralRestoreKey"};
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options: options];


        status = SEND_IDLE;
        currentOffset = 0;
        advertise = NO;
        self.startSignal = [@"START" dataUsingEncoding:NSASCIIStringEncoding];
        self.endSignal = [@"END" dataUsingEncoding:NSASCIIStringEncoding];
    }
    return self;
}


-(void) shutdownAdvetisement {
    advertise = NO;
    [self resetAdvertisement];
}

-(void) startupAdvetisement {
    advertise = YES;
    [self resetAdvertisement];
}

-(void) resetAdvertisement {
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Can't reset advertising, bluetooth is off.");
        return;
    }

    if(!advertise) {
        NSLog(@"shutting advertising down");
        [self.peripheralManager stopAdvertising];
    } else {
        if(![self.peripheralManager isAdvertising]) {
            NSLog(@"starting up advertisement");

            //  Note: CBAdvertisementDataServiceUUIDsKey and CBAdvertisementDataLocalNameKey are advertised when your app is in a foreground,
            // and not advertised in background mode
            [self.peripheralManager startAdvertising: self.advertisementData];

        }
    }

}


@end