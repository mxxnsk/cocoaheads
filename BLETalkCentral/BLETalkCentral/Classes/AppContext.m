//
// Created by Maxim Ignatyev on 6/12/14.
//
//


#import "AppContext.h"
#import "BLETalkAppDelegate.h"


@implementation AppContext {

}
+ (AppContext *)instance {
    BLETalkAppDelegate * app = (BLETalkAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!app.appContext) {
        app.appContext = [[AppContext alloc] init];
    }
    return app.appContext;
}

@end