//
//  BLETalkViewController.h
//  BLETalkCentral
//
//  Created by Maxim on 6/12/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceTableCell.h"

@class BLETalkCentralService;

@interface BLETalkViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *table;
@property(nonatomic, strong) BLETalkCentralService *service;
@property(nonatomic, strong) UINib *cellNib;
@end

@interface BLETalkViewController (Table)<UITableViewDataSource, UITableViewDelegate, DeviceTableCellDelegate>

@end


