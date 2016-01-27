<@header?interpret />
<#assign curr = entities[current_entity] />

#import "${curr.name}RestTestBase.h"
#import "${curr.name}WebServiceClientAdapter.h"

/** ${curr.name} Rest test class */
@interface ${curr.name}RestTest : ${curr.name}RestTestBase

@end