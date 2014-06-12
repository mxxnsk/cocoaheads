//
//  BLETalkViewController.h
//  BLETalk
//
//  Created by Maxim on 6/11/14.
//  Copyright (c) 2014 Cocoaheads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLETalkViewController : UIViewController

- (IBAction)killAction:(id)sender;

@property(nonatomic, copy) NSString *lastMessage;
@end