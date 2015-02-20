<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "RpcTest.h"
#import "${curr.name}WebServiceClientAdapter.h"

@interface ${curr.name}RpcTest : RpcTest

@property ${curr.name}WebServiceClientAdapter* webAdapter;

- (void) testGet;
- (void) testGetAll;
- (void) testInsert;
- (void) testUpdate;

@end