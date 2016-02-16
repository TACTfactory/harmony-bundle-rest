<@header?interpret />
<#include utilityPath + "all_imports.ftl" />

#import "RestTest.h"
#import "${curr.name}WebServiceClientAdapter.h"

@interface ${curr.name}RestTestBase : RestTest

@property ${curr.name}WebServiceClientAdapter *webAdapter;
@property ${curr.name} *entity;
@property NSMutableArray *entities;
@property int nbEntities;

- (void) testGet;
- (void) testGetAll;
- (void) testInsert;
- (void) testUpdate;
- (void) testDelete;

@end