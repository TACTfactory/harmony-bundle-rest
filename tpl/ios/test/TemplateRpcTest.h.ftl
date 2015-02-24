<@header?interpret />
<#assign curr = entities[current_entity] />

#import "RpcTest.h"
#import "${curr.name}WebServiceClientAdapter.h"

/** ${curr.name} RPC test class */
@interface ${curr.name}RpcTest : RpcTest

@end