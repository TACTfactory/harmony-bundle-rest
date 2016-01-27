<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "RestTest.h"
#import "${curr.name}WebServiceClientAdapter.h"

@interface ${curr.name}RestTestBase : RestTest

@property ${curr.name}WebServiceClientAdapter* webAdapter;

- (void) testGet;
- (void) testGetAll;
- (void) testInsert;
- (void) testUpdate;

@end