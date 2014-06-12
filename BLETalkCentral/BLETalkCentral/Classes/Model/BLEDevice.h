//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import <Foundation/Foundation.h>


typedef enum ConnectStep {
    csUnknown,
    csDiscovered,
    csConnecting,
    csConnected,
    csConnectFailed,
    csService,
    csReady,
    csBlacklisted

} ConnectStep;

#define SEND_IDLE  1
#define SEND_START 2
#define SEND_DATA  3
#define SEND_END   4




@class CBPeripheral;


@interface BLEDevice : NSObject
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) CBPeripheral * peripheral;
@property (assign, nonatomic) ConnectStep connectStep;

@property (strong, nonatomic) NSData * dataToSend;
@property (assign, nonatomic) int currentDataOffset;
@property (assign, nonatomic) int extendedState;
@property (nonatomic, strong) NSNumber * rssi;



-(NSString *)connectStepDescription;

@end