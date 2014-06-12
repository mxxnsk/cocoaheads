//
//  DeviceTableCell.m
//  BLETalkCentral
//
//  Created by Maxim on 6/12/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceTableCell.h"
#import "BLEDevice.h"

@implementation DeviceTableCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ble:) name:@"BLE" object:nil];
}

-(void)ble:(NSNotification *)notification {
    
    if(notification.object && notification.object != self.device) {
        return;
    }
    
   
    
    NSString * title = self.device.peripheral.state == CBPeripheralStateDisconnected ? @"Connect" : @"Disconnect";
    
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(tapOnAction:) forControlEvents:UIControlEventTouchUpInside];

}


-(NSString*) stateDescription: (CBPeripheralState) state{

    if(state == CBPeripheralStateConnected) {
        return @"Connected";
    } else if(state == CBPeripheralStateConnecting) {
        return @"Connecting";
    } else {
        return @"Disconnected";
    }
}

-(void) setData:(BLEDevice *)data delegate:(id<DeviceTableCellDelegate>)d {
    actionDelegate = d;
    self.device = data;
    self.nameLabel.text = _device.name;
    self.uuidLabel.text = [_device.peripheral.identifier UUIDString];

    self.statusLabel.text = [self stateDescription:_device.peripheral.state] ;

    int value = [_device.rssi integerValue];
    self.avgRssiLable.textColor = value > -50 ? [UIColor greenColor] : value > -60 ? [UIColor yellowColor] : value > -70 ? [UIColor orangeColor] : [UIColor redColor];



    self.avgRssiLable.text = value ? [NSString stringWithFormat:@"%ddB", value] : @"";
    [self ble:nil];
}

- (IBAction)tapOnSend:(id)sender {
    UIButton * b = sender;

    [actionDelegate onDeviceTableCellSend:self data: (b.tag == 1 ? [@"RED" dataUsingEncoding:NSASCIIStringEncoding] : [@"GREEN" dataUsingEncoding:NSASCIIStringEncoding])];
}

- (IBAction)tapOnAction:(id)sender {
    [actionDelegate onDeviceTableCellAction:self];
}@end
