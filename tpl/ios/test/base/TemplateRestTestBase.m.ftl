<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "${curr.name}RestTest.h"
<#list InheritanceUtils.getAllChildren(curr) as child>
#import "${child.name?cap_first}TestUtils.h"
</#list>
//#import "${curr.name}TestUtils.h"
#import "AppDelegate.h"


/** ${curr.name} Rest Test.
 * 
 * @see android.app.Fragment
 */
 
@implementation ${curr.name?cap_first}RestTestBase

- (void)setUp {
    [super setUp];
    
    self.webAdapter = [${curr.name?cap_first}WebServiceClientAdapter new];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testGet {

}

- (void) testGetAll {

}

- (void) testInsert {

}

- (void) testUpdate {

}
@end