<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "${curr.name}RpcTest.h"
<#list InheritanceUtils.getAllChildren(curr) as child>
#import "${child.name?cap_first}Utils.h"
</#list>
#import "${curr.name}Utils.h"
#import "AppDelegate.h"


/** ${curr.name} RPC Test.
 * 
 * @see android.app.Fragment
 */
 
@implementation ${curr.name?cap_first}RpcTest

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