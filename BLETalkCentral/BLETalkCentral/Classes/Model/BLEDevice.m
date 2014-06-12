//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"



@implementation BLEDevice {

}
-(NSString *)connectStepDescription {
    switch(self.connectStep) {
        case csDiscovered: return @"Discovered";
        case csConnected: return @"Connected";
        case csConnecting: return @"Connecting";
        case csConnectFailed: return @"Connection Failed";
        case csService: return @"Service Found";
        case csReady: return @"Ready";
        case csBlacklisted: return @"Blacklisted";
        default:return @"Unknown";
    }
}
@end