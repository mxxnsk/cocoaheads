//
// Created by Maxim Ignatyev on 6/11/14.
//
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>




#define BLE_SERVICE_UUID "c290064f-1abf-42bd-b51c-64b3c3b719ab"


#define BLE_RECEIVE_UUID  "b2458c60-71fc-43c9-84c3-e6a5afcbf708"
#define BLE_TRANSMIT_UUID  "4e8d4963-d0c8-4ec1-bc39-be37f2ffc7c9"
#define BLE_WRITE_LEN    20


#define SEND_IDLE  1
#define SEND_START 2
#define SEND_DATA  3
#define SEND_END   4


@interface BLETalkPeripheralService : NSObject {
    int currentOffset;
    int status; //
    BOOL advertise;
}



@property (strong, nonatomic) CBPeripheralManager * peripheralManager;

@property (strong, nonatomic) CBMutableCharacteristic * characteristicReceive;
@property (strong, nonatomic) CBMutableCharacteristic * characteristicTransmit;

@property (strong, nonatomic) CBMutableService * service;
@property (strong, nonatomic) NSMutableData * dataToSend;
@property (strong, nonatomic) NSMutableData * dataReceived;
@property (strong, nonatomic) NSData * startSignal;
@property (strong, nonatomic) NSData * endSignal;


@property(nonatomic, strong) NSDictionary *advertisementData;

+(BLETalkPeripheralService *) service;
-(void) shutdownAdvetisement;
-(void) startupAdvetisement;
- (void)resetAdvertisement;


@end

@interface BLETalkPeripheralService(CBPeripheralManagerDelegate)<CBPeripheralManagerDelegate>


@end
