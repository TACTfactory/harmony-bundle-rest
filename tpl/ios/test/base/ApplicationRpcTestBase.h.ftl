<@header?interpret />

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "TestDBBase.h"

@interface RpcTest : TestDBBase 
    @protected dispatch_semaphore_t semaphore;
    
- (void) testIsOnline;


@end