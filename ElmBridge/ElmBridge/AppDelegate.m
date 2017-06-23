//
//  AppDelegate.m
//  ElmBridge
//
//  Created by Palmer Paul on 6/6/17.
//  Copyright © 2017 Palmer Paul. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _jsvmThread = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(runJSVMThread)
                                            object:nil];
    [_jsvmThread start];
}


- (void)runJSVMThread {
    [[[ChakraProxy alloc] init] run];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    
    while (true) {
        [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}




@end
