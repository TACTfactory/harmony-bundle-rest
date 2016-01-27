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

#import "ResourceWebServiceClientAdapterBase.h"

/**
 * 
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony. 
 * You should edit ResourceWebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@implementation ResourceWebServiceClientAdapterBase

/** JSON Object Image pattern. */
+ (NSString *) JSON_OBJECT_RESOURCE { return @"Resource"; }
/** JSON_ID attributes. */
+ (NSString *) JSON_ID { return @"id"; }
/** JSON_PATH attributes. */
+ (NSString *) JSON_PATH { return @"path"; }

<#if sync>
/** JSON_SERVERID attributes. */
+ (NSString *) JSON_SERVERID { return @"serverId"; }
/** JSON_ORIGINALPATH attributes. */
+ (NSString *) JSON_ORIGINALPATH { return @"originalpath"; }
/** JSON_SYNC_UDATE attributes. */
+ (NSString *) JSON_SYNC_UDATE { return @"sync_uDate"; }
/** JSON_SYNC_DTAG attributes. */
+ (NSString *) JSON_SYNC_DTAG { return @"sync_dTag"; }
/** JSON_MOBILE_ID attributes. */
+ (NSString *) JSON_MOBILE_ID { return @"mobileId"; }
/** JSON_HASH attributes. */
+ (NSString *) JSON_HASH { return @"hash"; }


/** Sync Date Format pattern. */
+ (NSString *) SYNC_UPDATE_DATE_FORMAT { return @"yyyy-MM-dd'T'HH:mm:ssZ"; }
</#if>

/** Resource REST Columns. */
+ (NSArray *) REST_COLS {
    return [NSArray arrayWithObjects:
            ResourceContract.COL_ID,
            ResourceContract.COL_PATH,<#if sync>
            ResourceContract.COL_SERVERID,
            ResourceContract.COL_SYNC_DTAG,
            ResourceContract.COL_SYNC_UDATE,
            ResourceContract.COL_HASH,</#if>
            nil];
};

- (NSString *) getUri {
    return @"resource";
}

- (NSMutableDictionary *) itemToJson:(EntityResourceBase *) item {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    @try {
    <#if sync>
        [params setValue:item.serverId
                  forKey:ResourceWebServiceClientAdapterBase.JSON_ID];
    <#else>
        [params setValue:[NSNumber numberWithInt:item.id]
                  forKey:ResourceWebServiceClientAdapterBase.JSON_ID];
    </#if>

        [params setValue:item.path
                  forKey:ResourceWebServiceClientAdapterBase.JSON_PATH];

    <#if sync>
        [params setValue:[NSNumber numberWithInt:item.id]
                  forKey:ResourceWebServiceClientAdapterBase.JSON_MOBILE_ID];

        [params setValue:[NSNumber numberWithBool:item.sync_dtag]
                  forKey:ResourceWebServiceClientAdapterBase.JSON_SYNC_DTAG];

        if (item.sync_uDate != nil) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:ResourceWebServiceClientAdapterBase.SYNC_UPDATE_DATE_FORMAT];

            [params setValue:[dateFormatter stringFromDate:item.sync_uDate]
                     forKey:ResourceWebServiceClientAdapterBase.JSON_SYNC_UDATE];
        }

        [params setValue:item.uuid
                  forKey:ResourceWebServiceClientAdapterBase.JSON_HASH];

        NSString *path = item.localPath;

        if (path == nil || path.length < 1) {
            path = item.path;
        }

        [params setValue:path forKey:ResourceWebServiceClientAdapterBase.JSON_ORIGINALPATH];
    </#if>

    } @catch(NSException *e) {
        NSLog(@"Exception: %@", e);
    }

    return params;
}

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items {
    return [self extractItems:json withParamName:paramName withItems:items withLimit:0];
}

- (int) extractItems:(NSMutableDictionary *) json
       withParamName:(NSString *) paramName
           withItems:(NSMutableArray *) items
           withLimit:(int) limit {
    NSArray *itemArray = [json objectForKey:paramName];

    int result = -1;

    if (itemArray != nil) {
        int count = (int) itemArray.count;

        if (limit > 0 && count > limit) {
            count = limit;
        }

        for (int i = 0; i < count; i++) {
            NSDictionary *jsonItem = itemArray[i];
            EntityResourceBase *item = [EntityResourceBase new];

            [self extract:[NSMutableDictionary dictionaryWithDictionary:jsonItem] withItem:item];

            if (item != nil) {
                [items addObject:item];
            }
        }

        result = (int) items.count;
    }

    if (![self jsonIsNull:json withProperty:@"Meta"]) {
        result = (int) [json objectForKey:@"Meta"];
    }

    return result;
}

- (void) delete:(EntityResourceBase *) resource withCallback:(void(^)(int)) callback {
    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];

            if ([self isValidJSON:json]) {
                if (callback != nil) {
                    callback(0);
                }
            } else {
                if (callback != nil) {
                    callback(-1);
                }
            }
        }
    };

    [self invokeRequest:DELETE
            withRequest:[NSString stringWithFormat:@"%@/%@%@",
                         [self getUri],
                         <#if sync>resource.serverId<#else>[NSNumber numberWithInt:resource.id]</#if>,
                         [ResourceWebServiceClientAdapterBase REST_FORMAT]]
             withParams:nil
           withCallback:restCallback];
}


- (void) getAll:(void(^)(NSArray *)) callback {
    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {
        NSMutableArray *items = [NSMutableArray new];

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];

            if ([self isValidJSON:json]) {
                [self extractItems:[json objectForKey:@"Resources"] withItems:items];
            }
        }

        if (callback != nil) {
            callback(items);
        }
    };

    [self invokeRequest:GET
            withRequest:[NSString stringWithFormat:@"%@%@",
                         [self getUri],
                         [ResourceWebServiceClientAdapterBase REST_FORMAT]]
             withParams:nil
           withCallback:restCallback];
}

- (void) get:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback {
    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];
            
            if ([self isValidJSON:json]) {
                [self extract:json withItem:item];
            }
        }

        if (callback != nil) {
            callback(item);
        }
    };

    [self invokeRequest:GET
            withRequest:[NSString stringWithFormat:@"%@/%@%@",
                         [self getUri],
                         <#if sync>item.serverId<#else>[NSNumber numberWithInt:item.id]</#if>,
                         [ResourceWebServiceClientAdapterBase REST_FORMAT]]
             withParams:nil
           withCallback:restCallback];
}

- (void) insert:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback {
    void ( ^restCallback )( HttpResponse* ) = ^(HttpResponse* object) {

        if (object.result != nil) {
            NSMutableDictionary* json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*) object.result];
            
            if ([self isValidJSON:json]) {
                NSString *originalPath = item.path;
                [self extract:json withItem:item];
                
                void (^uploadCallback )(HttpResponse *) = ^(HttpResponse *object) {
                    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:
                                                 (NSDictionary *) object.result];

                    if ([self isValidJSON:json]) {
                        [self extract:json withItem:item];
                    } else {
                        item.path = originalPath;
                        <#if sync>item.sync_uDate = [NSDate date];</#if>
                    }

                    if (callback != nil) {
                        callback(item);
                    }
                };
                
                [self upload:item withCallback:uploadCallback];
            }
        } else {
            if (callback != nil) {
                callback(item);
            }
        }
    };

    [self invokeRequest:POST
            withRequest:[NSString stringWithFormat:@"%@%@",
                         [self getUri],
                         [ResourceWebServiceClientAdapterBase REST_FORMAT]]
             withParams:[self itemToJson:item]
           withCallback:restCallback];
}

- (void) update:(EntityResourceBase *) item withCallback:(void(^)(EntityResourceBase *)) callback {

    if (<#if sync>item.serverId != nil && item.serverId != 0<#else>item.id != 0</#if>) {
        void ( ^restCallback )(HttpResponse*) = ^(HttpResponse* object) {

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];
            
            if ([self isValidJSON:json]) {
                NSString *originalPath = item.path;
                [self extract:json withItem:item];
                
                void ( ^uploadCallback )(HttpResponse *) = ^(HttpResponse *object) {
                    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:
                                                 (NSDictionary *) object.result];

                    if ([self isValidJSON:json]) {
                        [self extract:json withItem:item];
                    } else {
                        item.path = originalPath;
                        <#if sync>item.sync_uDate = [NSDate date];</#if>
                    }

                    if (callback != nil) {
                        callback(item);
                    }
                };
                
                [self upload:item withCallback:uploadCallback];
            }
        } else {
            if (callback != nil) {
                callback(item);
            }
        }
    };
        
        [self invokeRequest:PUT withRequest:[NSString stringWithFormat:@"%@/%@%@",
                                             [self getUri],
                                             <#if sync>item.serverId<#else>[NSNumber numberWithInt:item.id]</#if>,
                                             [ResourceWebServiceClientAdapterBase REST_FORMAT]]
                 withParams:[self itemToJson:item]
               withCallback:restCallback];
        
    } else {
        [self insert:item withCallback:callback];
    }
}

- (void) upload:(EntityResourceBase *) item withCallback:(void(^)(HttpResponse *)) callback {
    NSMutableDictionary *json = [self itemToJson:item];
    
    [json setValue:item.<#if sync>localPath<#else>path</#if> forKey:[ImageUtils IMAGE_KEY_JSON]];
    
    [self invokeRequest:POST withRequest:[NSString stringWithFormat:@"%@/upload/%@%@",
                                         [self getUri],
                                         <#if sync>item.serverId<#else>[NSNumber numberWithInt:item.id]</#if>,
                                         [ResourceWebServiceClientAdapterBase REST_FORMAT]]
             withParams:json
           withCallback:callback];
}

- (bool) extract:(NSMutableDictionary *)json withItem:(EntityResourceBase *)item {
    bool result = [self isValidJSON:json];

    if (result) {
        @try {
        if (![self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_ID]]) {
            <#if sync>
            id server_id = [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ID]];
            
            if (server_id != nil && [server_id isKindOfClass:[NSString class]]) {
                server_id = [[NSNumberFormatter new]
                             numberFromString:[json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ID]]];
            }
            
            if (server_id != 0) {
                item.serverId = server_id;
            }
            <#else>
            item.id = [[json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ID]] intValue];
            </#if>
        }

        <#if sync>
        if (![self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_MOBILE_ID]]) {
            item.id = [[json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ID]] intValue];
        }
        
        if (![self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_ORIGINALPATH]]) {
            item.localPath = [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ORIGINALPATH]];
        }
        
        if (![self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_SYNC_DTAG]]) {
            item.sync_dtag = [[json objectForKey:[ResourceWebServiceClientAdapterBase JSON_SYNC_DTAG]] boolValue];
        }
        
        if (![self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_SYNC_UDATE]]) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:[ResourceWebServiceClientAdapterBase SYNC_UPDATE_DATE_FORMAT]];

            @try {
                NSDate *date = [dateFormatter dateFromString:
                                [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_SYNC_UDATE]]];
                item.sync_uDate = date;
            } @catch(NSException *e) {
                NSLog(@"Exception: %@", e);
            }
        }

        item.uuid = [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_HASH]];
        </#if>

        } @catch (NSException *exception) {
            
        }
    }
    
    return result;
}

- (bool) isValidJSON:(NSObject *) json {
    return [json isKindOfClass:[NSDictionary class]];
}

- (NSMutableDictionary *) itemIdToJson:(EntityResourceBase *) item {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    @try {
        NSString *path = item.<#if sync>localPath<#else>path</#if>;
    
        [params setValue:<#if sync>item.serverId<#else>[NSNumber numberWithInt:item.id]</#if> forKey:ResourceWebServiceClientAdapterBase.JSON_ID];
        [params setValue:path forKey:ResourceWebServiceClientAdapterBase.JSON_<#if sync>ORIGINAL</#if>PATH];
    } @catch(NSException* e) {
        NSLog(@"Exception: %@", e);
    }

    return params;
}

- (bool) extractResource:(NSMutableDictionary *) json withResource:(EntityResourceBase *) resource {
    bool result = false;

    @try {
        if ([self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_PATH]]) {
            resource.path = [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_PATH]];
            result = true;
        }
        <#if sync>

        if ([self jsonIsNull:json withProperty:[ResourceWebServiceClientAdapterBase JSON_ORIGINALPATH]]) {
            resource.localPath =  [json objectForKey:[ResourceWebServiceClientAdapterBase JSON_ORIGINALPATH]];
        }
        </#if>
    } @catch (NSException *exception) {
    }

}

- (NSString *) getSyncUri {
    return @"/sync";
}

@end
