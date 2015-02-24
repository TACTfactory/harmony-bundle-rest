<@header?interpret />
<#assign curr = entities[current_entity] />

#import "${curr.name?cap_first}WebServiceClientAdapter.h"

/**
 * RPC class for {@link ${curr.name?cap_first}} WebServiceClient adapters.
 */
@implementation ${curr.name?cap_first}WebServiceClientAdapter

@end