<@header?interpret />

#import "RpcTestBase.h"
#import "AppDelegate.h"

@implementation RpcTest

- (void)setUp {
    [super setUp];
    
    semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown {
    [super tearDown];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    //dispatch_release(semaphore);
}

- (void) testIsOnline {

}

@end