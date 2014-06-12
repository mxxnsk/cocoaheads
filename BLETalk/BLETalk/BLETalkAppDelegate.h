//
//  BLETalkAppDelegate.h
//  BLETalk
//
//  Created by Maxim on 6/11/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLETalkPeripheralService;

@interface BLETalkAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLETalkPeripheralService *service;

@end