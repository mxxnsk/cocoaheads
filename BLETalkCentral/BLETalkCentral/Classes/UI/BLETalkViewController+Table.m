//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import "BLETalkViewController.h"
#import "AppContext.h"
#import "DeviceTableCell.h"
#import "BLEDevice.h"
#import "BLETalkCentralService.h"


@implementation BLETalkViewController (Table)

static NSString *Identifier = @"DeviceTableCell";

- (DeviceTableCell *)cellFromNib {

    if (!self.cellNib) {
        self.cellNib = [UINib nibWithNibName:Identifier bundle:nil];
    }

    DeviceTableCell * cell = (DeviceTableCell *) [[self.cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    cell.contentView.userInteractionEnabled = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 210;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AppCTX.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DeviceTableCell *cell = (DeviceTableCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];

    if (!cell) {
        cell = [self cellFromNib];
    }

    NSUInteger index = (NSUInteger) indexPath.row;

    BLEDevice * device = index >= AppCTX.devices.count ? nil : [AppCTX.devices objectAtIndex:index];

    if(!device) {
        NSLog(@"wrong index");
    }

    if(device) {
        [cell setData:device delegate:self];
    } else {
        cell.nameLabel.text = @"";
        cell.uuidLabel.text = @"";
        cell.statusLabel.text = @"";
        cell.signalLabel.text = @"";
        cell.device = nil;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


- (void)onDeviceTableCellAction:(DeviceTableCell *)cell {
    if(cell.device.peripheral.state == CBPeripheralStateDisconnected) {
        NSLog(@"connect device");

        [self.service connectDevice:cell.device];
    } else if(cell.device.peripheral.state == CBPeripheralStateConnected) {
        NSLog(@"disconnect device");
        [self.service disconnectDevice: cell.device];
    }
}

- (void)onDeviceTableCellSend:(DeviceTableCell *)cell data: (NSData*) data {
     [self.service write:data];

}

@end