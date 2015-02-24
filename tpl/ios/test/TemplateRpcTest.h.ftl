<@header?interpret />
<#assign curr = entities[current_entity] />

#import "${curr.name}RpcTestBase.h"
#import "${curr.name}WebServiceClientAdapter.h"

/** ${curr.name} RPC test class */
@interface ${curr.name}RpcTest : ${curr.name}RpcTestBase

@end