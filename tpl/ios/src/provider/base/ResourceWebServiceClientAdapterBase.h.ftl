<#assign sync=false />
<#assign rest=false />
<#list entities?values as entity>
    <#if entity.options.rest??>
        <#assign rest=true />
    </#if>
    <#if entity.options.sync??>
        <#assign sync=true />
    </#if>
</#list>
<@header?interpret />
<#assign curr = entities[current_entity] />

#import "ResourceWebServiceClientAdapter.h"
#import "WebServiceClientAdapter.h"
#import "ResourceContract.h"
#import "EntityResourceBase.h"
#import "ImageUtils.h"

/**
 * 
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony. 
 * You should edit ResourceWebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@interface ResourceWebServiceClientAdapterBase : <#if sync>SyncClientAdapterBase<SyncClientAdapterResource> <#else>WebServiceClientAdapter</#if>

/** JSON Object Image pattern. */
+ (NSString *) JSON_OBJECT_RESOURCE;
/** JSON_ID attributes. */
+ (NSString *) JSON_ID;
/** JSON_PATH attributes. */
+ (NSString *) JSON_PATH;

<#if sync>
/** JSON_SERVERID attributes. */
+ (NSString *) JSON_SERVERID;
/** JSON_ORIGINALPATH attributes. */
+ (NSString *) JSON_ORIGINALPATH;
/** JSON_SYNC_UDATE attributes. */
+ (NSString *) JSON_SYNC_UDATE;
/** JSON_SYNC_DTAG attributes. */
+ (NSString *) JSON_SYNC_DTAG;
/** JSON_MOBILE_ID attributes. */
+ (NSString *) JSON_MOBILE_ID;
/** JSON_HASH attributes. */
+ (NSString *) JSON_HASH;

/** Sync Date Format pattern. */
+ (NSString *) SYNC_UPDATE_DATE_FORMAT;
</#if>

/** Resource REST Columns. */
+ (NSArray *) REST_COLS;

- (NSString *) getUri;

- (NSMutableDictionary *) itemToJson:(EntityResourceBase *) item;

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items;

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items
           withLimit:(int) limit;

- (void) delete:(EntityResourceBase *) resource withCallback:(void(^)(int)) callback;

- (void) getAll:(void(^)(NSArray *)) callback;

- (void) get:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback;

- (void) insert:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback;

- (void) update:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback;

- (void) upload:(EntityResourceBase *) item withCallback:(void(^)(HttpResponse *)) callback;

- (bool) extract:(NSMutableDictionary *)json withItem:(EntityResourceBase *)item;

- (NSMutableDictionary *) itemIdToJson:(EntityResourceBase *) item;

- (bool) extractResource:(NSMutableDictionary *) json withResource:(EntityResourceBase *) resource;

@end
