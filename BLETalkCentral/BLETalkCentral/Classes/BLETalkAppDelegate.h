//
//  BLETalkAppDelegate.h
//  BLETalkCentral
//
//  Created by Maxim on 6/12/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppContext.h"


@interface BLETalkAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppContext * appContext;

@end