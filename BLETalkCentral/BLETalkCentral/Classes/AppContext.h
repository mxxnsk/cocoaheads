//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import <Foundation/Foundation.h>

#define AppCTX [AppContext instance]

@interface AppContext : NSObject

@property (strong, nonatomic) NSMutableArray * devices;


+(AppContext *)instance;

@end