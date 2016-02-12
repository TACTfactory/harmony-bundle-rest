<@header?interpret />

#import "RestTestBase.h"
#import "AppDelegate.h"
#import "Config.h"
#import "TestUtils.h"

@implementation RestTestBase

- (void)setUp {
    [super setUp];

    semaphore = dispatch_semaphore_create(0);

    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    //dispatch_release(semaphore);

    [[LSNocilla sharedInstance] stop];
    [[LSNocilla sharedInstance] clearStubs];
}

- (void) stubInsert:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter {
    NSString *jsonString = [TestUtils jsonToString:[adapter itemToJson:entity]];

    stubRequest(@"POST",
                [NSString stringWithFormat:@"%@%@.json",
                 Config.REST_URL_DEV,
                 [adapter getUri]])
    .andReturn(201)
    .withBody(jsonString)
    .withHeaders(@{@"Content-Type" : @"application/json"});
}

- (void) stubUpdate:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter {
    NSString *jsonString = [TestUtils jsonToString:[adapter itemToJson:entity]];

    stubRequest(@"PUT",
                [NSString stringWithFormat:@"%@%@/%@.json",
                 Config.REST_URL_DEV,
                 [adapter getUri],
                 [self getId:entity]])
    .andReturn(201)
    .withBody(jsonString)
    .withHeaders(@{@"Content-Type" : @"application/json"});
}

- (void) stubDelete:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter {
    stubRequest(@"DELETE",
                [NSString stringWithFormat:@"%@%@/%@.json",
                 Config.REST_URL_DEV,
                 [adapter getUri],
                 [self getId:entity]])
    .andReturn(201)
    .withHeaders(@{@"Content-Type" : @"application/json"});
}

- (void) stubGet:(id) entity withWebServiceAdapter:(WebServiceClientAdapter *) adapter {
    NSString *jsonString = [TestUtils jsonToString:[adapter itemToJson:entity]];

    stubRequest(@"GET",
                [NSString stringWithFormat:@"%@%@/%@.json",
                 Config.REST_URL_DEV,
                 [adapter getUri],
                 [self getId:entity]])
    .andReturn(201)
    .withBody(jsonString)
    .withHeaders(@{@"Content-Type" : @"application/json"});
}

- (void) stubGetAll:(NSString *) entityType
       withEntities:(NSArray *) entities
withWebServiceAdapter:(WebServiceClientAdapter *) adapter {

    NSString *jsonString = [NSString stringWithFormat:@"{\"%@\" : [%@]}",
                            entityType,
                            [TestUtils jsonListToString:[adapter itemsToJson:entities]]];

    stubRequest(@"GET",
                [NSString stringWithFormat:@"%@%@.json",
                 Config.REST_URL_DEV,
                 [adapter getUri]])
    .andReturn(201)
    .withBody(jsonString)
    .withHeaders(@{@"Content-Type" : @"application/json"});
}

- (void) testIsOnline {
    dispatch_semaphore_signal(semaphore);
}

- (NSObject *) getId:(id) entity {
    return [entity valueForKey:@"id"];
}

@end