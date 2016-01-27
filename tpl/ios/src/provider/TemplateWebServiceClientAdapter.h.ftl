<@header?interpret />
<#assign curr = entities[current_entity] />

#import "${curr.name}WebServiceClientAdapterBase.h"

/**
 * RPC class for {@link ${curr.name}} WebServiceClient adapters.
 */
@interface ${curr.name}WebServiceClientAdapter : ${curr.name}WebServiceClientAdapterBase

@end