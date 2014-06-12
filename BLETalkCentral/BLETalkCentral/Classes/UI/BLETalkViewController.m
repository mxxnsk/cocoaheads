//
//  BLETalkViewController.m
//  BLETalkCentral
//
//  Created by Maxim on 6/12/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import "BLETalkViewController.h"
#import "BLETalkCentralService.h"

@implementation BLETalkViewController

BOOL notificationRegistered = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerNotification];
    self.service = [[BLETalkCentralService alloc] init];
    [_service startService];
    self.table.dataSource = self;
    self.table.delegate  = self;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) unregisterNotifications {
    if(!notificationRegistered) {
        return;
    }
    notificationRegistered = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) registerNotification {
    if(notificationRegistered) {
        return;
    }
    notificationRegistered = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessage:) name:@"BLE" object:nil];
}

-(void) onMessage: (NSNotification *) notification {
    [self.table reloadData];
}


- (IBAction)onRestartScan:(id)sender {
    [_service startScan];
}


- (IBAction)onScanSwitchChanged:(id)sender {
    UISwitch * sw = sender;
    if(sw.isOn) {
        [_service startScan];
    } else {
        [_service stopScan];
    }
}


@end