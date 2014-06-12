//
//  DeviceTableCell.h
//  BLETalkCentral
//
//  Created by Maxim on 6/12/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDevice.h"

@protocol DeviceTableCellDelegate;

@interface DeviceTableCell : UITableViewCell   {
    id<DeviceTableCellDelegate> actionDelegate;
}

@property (strong, nonatomic) BLEDevice * device;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *uuidLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *signalLabel;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *disconnectStatus;
@property (strong, nonatomic) IBOutlet UILabel *avgRssiLable;

-(void) setData:(BLEDevice *)data delegate:(id<DeviceTableCellDelegate>)d;

- (IBAction)tapOnAction:(id)sender;
- (IBAction)tapOnSend:(id)sender;
@end


@protocol DeviceTableCellDelegate <NSObject>

-(void) onDeviceTableCellAction:(DeviceTableCell *)cell;
-(void) onDeviceTableCellSend:(DeviceTableCell *)cell data: (NSData *) data;

@end
