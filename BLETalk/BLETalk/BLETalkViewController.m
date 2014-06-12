//
//  BLETalkViewController.m
//  BLETalk
//
//  Created by Maxim on 6/11/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import "BLETalkViewController.h"

@interface BLETalkViewController () {
   BOOL notificationRegistered;
}
@end

@implementation BLETalkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}



-(void) onMessage: (NSNotification *) notification {
    NSString * message = notification.object;
    self.lastMessage = message;

    if([@"GREEN" isEqualToString:_lastMessage]) {
        self.view.backgroundColor = [UIColor greenColor];
    } else if ([@"RED" isEqualToString:_lastMessage]) {
        self.view.backgroundColor = [UIColor redColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}


-(void) registerNotification {
    if(notificationRegistered) {
        return;
    }
    notificationRegistered = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessage:) name:@"UPDATEUI" object:nil];
}

-(void) unregisterNotifications {
    if(!notificationRegistered) {
        return;
    }
    notificationRegistered = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)killAction:(id)sender {
    kill(getpid(), SIGKILL);
}
@end