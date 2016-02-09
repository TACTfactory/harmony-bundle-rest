<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "${curr.name}RestTestBase.h"
<#list InheritanceUtils.getAllChildren(curr) as child>
#import "${child.name?cap_first}TestUtils.h"
#import "${child.name?cap_first}DataLoader.h"
</#list>
#import "AppDelegate.h"

/** ${curr.name} Rest Test.
 *
 */

@implementation ${curr.name?cap_first}RestTestBase

- (void)setUp {
    [super setUp];

    self.webAdapter = [${curr.name?cap_first}WebServiceClientAdapter new];
    self.entities = [NSMutableArray new];

<#list InheritanceUtils.getAllChildren(curr) as child>
    [self.entities addObjectsFromArray:[[${child.name?cap_first}DataLoader get${child.name?cap_first}DataLoader] getItems] allValues]];
</#list>

    if (self.entities.count > 0) {
        self.entity = [self.entities objectAtIndex:[TestUtils generateRandomInt:0
                                                                   withMaxValue:self.entities.count - 1]];
    }

<#list InheritanceUtils.getAllChildren(curr) as child>
    self.nbEntities += [[[${child.name?cap_first}DataLoader get${child.name?cap_first}DataLoader] getItems] count];
</#list>
}

- (void)tearDown {
    [super tearDown];
}

- (void) testGet {
    [self stubGet:self.entity withWebServiceAdapter:self.webAdapter];

    [self.webAdapter get:self.entity withCallback:^(${curr.name?cap_first} *result) {
        [${curr.name?cap_first}TestUtils equals:self.entity withCompare:result];

        dispatch_semaphore_signal(semaphore);
    }];
}

- (void) testGetAll {
    [self stubGetAll:@"${curr.name?cap_first}s" withEntities:self.entities withWebServiceAdapter:self.webAdapter];

    [self.webAdapter getAll:^(NSArray *result) {
        XCTAssertEqual(result.count, self.entities.count);

        dispatch_semaphore_signal(semaphore);
    }];
}

- (void) testInsert {
    [self stubInsert:self.entity withWebServiceAdapter:self.webAdapter];

    [self.webAdapter insert:self.entity withCallback:^(${curr.name?cap_first} *result) {
        [${curr.name?cap_first}TestUtils equals:self.entity withCompare:result];

        dispatch_semaphore_signal(semaphore);
    }];
}

- (void) testUpdate {
    [self stubUpdate:self.entity withWebServiceAdapter:self.webAdapter];

    [self.webAdapter update:self.entity withCallback:^(${curr.name?cap_first} *result) {
        [${curr.name?cap_first}TestUtils equals:self.entity withCompare:result];

        dispatch_semaphore_signal(semaphore);
    }];
}

- (void) testDelete {
    [self stubDelete:self.entity withWebServiceAdapter:self.webAdapter];

    [self.webAdapter remove:self.entity withCallback:^(int result) {
        XCTAssertNotEqual(result, -1);

        dispatch_semaphore_signal(semaphore);
    }];
}

@end