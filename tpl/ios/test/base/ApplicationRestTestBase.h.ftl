<@header?interpret />

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <Nocilla/Nocilla.h>
#import "TestDBBase.h"
#import "WebServiceClientAdapter.h"

@interface RestTestBase : TestDBBase {
    @protected dispatch_semaphore_t semaphore;
}

- (void) stubInsert:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter;

- (void) stubUpdate:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter;

- (void) stubDelete:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter;

- (void) stubGet:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter;

- (void) stubGetAll:(NSString *) entityType
       withEntities:(NSArray *) entities
withWebServiceAdapter:(WebServiceClientAdapter *) adapter;

- (void) testIsOnline;


@end