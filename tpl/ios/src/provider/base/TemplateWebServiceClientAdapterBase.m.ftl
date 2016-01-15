<@header?interpret />
<#include utilityPath + "all_imports.ftl" />
<#assign curr = entities[current_entity] />
<#function alias name object=false>
    <#if object>
        <#return "JSON_OBJECT_"+name?upper_case />
    <#else>
        <#return "JSON_"+name?upper_case />
    </#if>
</#function>
<#function typeToJsonType field>
    <#if (field.harmony_type?lower_case != "relation")>
        <#switch FieldsUtils.getObjectiveType(field)?lower_case>
            <#case "int">
                <#return "int" />
                <#break />
            <#case "float">
                <#return "float" />
                <#break />
            <#case "double">
                <#return "double" />
                <#break />
            <#case "long">
                <#return "long" />
                <#break />
            <#case "boolean">
                <#return "bool" />
                <#break />
            <#case "enum">
                <#assign enumType = enums[field.enum.targetEnum] />
                <#if enumType.id??>
                    <#assign idEnumType = enumType.fields[enumType.id].harmony_type?lower_case />
                    <#if (idEnumType == "int") >
                        <#return "int" />
                    <#else>
                        <#return "NSString" />
                    </#if>
                <#else>
                    <#return "NSString" />
                </#if>
                <#break />
            <#default>
                <#return "NSString" />
                <#break />
        </#switch>
    <#else>
        <#if (field.relation.type=="ManyToMany" || field.relation.type=="OneToMany")>
            <#return "JSONObject" />
        <#else>
            <#return "JSONObject" />
        </#if>
    </#if>
</#function>
<#function getFormatter field>
    <#assign ret="ISODateTimeFormat." />
    <#if (field.harmony_type?lower_case=="datetime")>
        <#assign ret=ret+"dateTime()" />
    <#elseif (field.harmony_type?lower_case=="time")>
        <#assign ret=ret+"dateTime()" />
    <#elseif (field.harmony_type?lower_case=="date")>
        <#assign ret=ret+"dateTime()" />
    </#if>
    <#return ret />
</#function>
<#function isRestEntity entityName>
    <#return entities[entityName].options.rest?? />
</#function>
<#function isInArray array var>
    <#list array as item>
        <#if (item==var)>
            <#return true />
        </#if>
    </#list>
    <#return false />
</#function>
<#assign restFields = [] />
<#list ViewUtils.getAllFields(curr)?values as field>
    <#if (!field.internal)>
        <#if (!field.relation??)>
            <#assign restFields = restFields + [field] />
        <#else>
            <#if (isRestEntity(field.relation.targetEntity))>
                <#if (field.relation.type=="OneToOne" || field.relation.type=="ManyToOne")>
                    <#assign restFields = restFields + [field] />
                </#if>
            </#if>
        </#if>
    </#if>
</#list>

#import "${curr.name}WebServiceClientAdapterBase.h"
#import "${curr.name}WebServiceClientAdapter.h"
<#if (InheritanceUtils.isExtended(curr))>
#import "${curr.inheritance.superclass.name}WebServiceClientAdapter.h"
</#if>
<#assign import_array = [curr.name] />
<#assign alreadyImportArrayList=false />
<#list curr.relations as relation>
        <#if (isRestEntity(relation.relation.targetEntity))>
            <#if (!isInArray(import_array, relation.relation.targetEntity))>
                <#assign import_array = import_array + [relation.relation.targetEntity] />
#import "${relation.relation.targetEntity}WebServiceClientAdapter.h"
#import "${relation.relation.targetEntity}SQLiteAdapter.h"
            </#if>
        </#if>
    </#list>

/**
 * 
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony. 
 * You should edit ${curr.name}WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@implementation ${curr.name}WebServiceClientAdapterBase

/** JSON Object ${curr.name} pattern. */
+ (NSString *) ${alias(curr.name, true)} { return @"${curr.name?cap_first}"; }
    <#list curr.fields?values as field>
        <#if (!field.internal)>
            <#if (!field.relation??) || (isRestEntity(field.relation.targetEntity))>
/** ${alias(field.name)} attributes. */
                <#if field.options.rest?? && field.options.rest.name != "" >
+ (NSString *) ${alias(field.name)} { return @"${field.options.rest.name}"; }

                <#else>
+ (NSString *) ${alias(field.name)} { return @"${field.name?uncap_first}"; }
                </#if>
            </#if>
        </#if>
    </#list>
<#if (curr.options.sync??)>
/** JSON mobile id. */
+ (NSString *) JSON_MOBILE_ID { return @"mobile_id"; }
/** Sync Date Format pattern. */
+ (NSString *) SYNC_UPDATE_DATE_FORMAT { return @"${curr.options.sync.updateDateFormatJava}"; }
</#if>
/** Rest Date Format pattern. */
+ (NSString *) REST_UPDATE_DATE_FORMAT { return @"${curr.options.rest.dateFormat}"; }

    <#if (InheritanceUtils.isExtended(curr))>
- (id) init {
    if (self = [super init]) {
        self->motherAdapter = [${curr.inheritance.superclass.name}WebServiceClientAdapter new];
    }

    return self;
}
    </#if>

- (NSString *) getUri {
    return @"${curr.options.rest.uri}";
}

- (int) getItemId:(${curr.name} *) item {
    <#if (curr.options.sync??)>
    int result = 0;

    if (item.serverId != nil) {
        result = [item.serverId intValue];
    }

    return result;
    <#else>
    return item.${curr.ids[0].name};
    </#if>
}

<#if curr.fields?size != 0>
- (bool) isValidJSON:(NSObject *)json {
    return [json isKindOfClass:[NSDictionary class]];
}

</#if>
- (int) extractItems:(NSArray *) jsonArray withItems:(NSMutableArray *) items {
    
    for (NSDictionary *json in jsonArray) {
        ${curr.name} *item = [${curr.name} new];
        
        if ([self extract:[NSMutableDictionary dictionaryWithDictionary:json] withItem:item]) {
            [items addObject:item];
        }
    }

    return (int) items.count;
}

- (NSMutableDictionary *) itemToJson:(${curr.name} *) ${curr.name?uncap_first} {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    @try {
        <#list curr.fields?values as field>
            <#if (!field.internal)>
                <#if (!field.relation??)>
                    <#if field.name?lower_case=="id"><#if !InheritanceUtils.isExtended(curr)>
        [params setValue:[NSNumber numberWithInt:[self getItemId:${curr.name?uncap_first}]]
                  forKey:${curr.name}WebServiceClientAdapter.JSON_ID];

                    </#if><#elseif (curr.options.sync?? && field.name=="serverId")><#if !InheritanceUtils.isExtended(curr)>
        [params setValue:[NSNumber numberWithInt:${curr.name?uncap_first}.id]
                  forKey:${curr.name}WebServiceClientAdapter.JSON_MOBILE_ID];

                    </#if><#elseif (curr.options.sync?? && field.name=="sync_uDate")><#if !InheritanceUtils.isExtended(curr)>
        if (${curr.name?uncap_first}.${field.name?uncap_first} != nil) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:${field.owner}WebServiceClientAdapter.SYNC_UPDATE_DATE_FORMAT];

            [params setValue:[dateFormatter stringFromDate:${curr.name?uncap_first}.${field.name?uncap_first}]
                     forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
        }

                    </#if><#elseif (FieldsUtils.getObjectiveType(field)?lower_case == "datetime")>
        if (${curr.name?uncap_first}.${field.name?uncap_first} != nil) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:${field.owner}WebServiceClientAdapter.REST_UPDATE_DATE_FORMAT];

            [params setValue:[dateFormatter stringFromDate:${curr.name?uncap_first}.${field.name?uncap_first}]
                      forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
        }

                    <#elseif (field.harmony_type=="string" || field.harmony_type=="text")>
        if (${curr.name?uncap_first}.${field.name?uncap_first} != nil) {
            [params setValue:${curr.name?uncap_first}.${field.name?uncap_first}
                      forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
        }

                    <#elseif (field.harmony_type=="enum")>
        //TODO enum
                    <#elseif (field.harmony_type=="int")>
        [params setValue:[NSNumber numberWithInt:${curr.name?uncap_first}.${field.name?uncap_first}]
                  forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
                    <#else>
                        <#if FieldsUtils.getObjectiveType(field)?lower_case=="string">
        [params setValue:${FieldsUtils.generateFieldContentType("item", field)}${curr.name?uncap_first}.${field.name?uncap_first}
                  forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
                        <#else>
        [params setValue:${FieldsUtils.generateFieldContentType("item", field)}${curr.name?uncap_first}.${field.name?uncap_first}]
                  forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
                        </#if>
                    </#if>
                <#else>
                    <#if (isRestEntity(field.relation.targetEntity))>
                        <#if (field.relation.type == "ManyToMany" || field.relation.type == "OneToMany")>
                            <#assign converter = "itemsIdToJson" />
                        <#else>
                            <#assign converter = "itemIdToJson" />
                        </#if>

        if (${curr.name?uncap_first}.${field.name?uncap_first} != nil) {
            ${field.relation.targetEntity}WebServiceClientAdapter *${field.name}Adapter = [${field.relation.targetEntity}WebServiceClientAdapter new];

            [params setValue:[${field.name}Adapter ${converter}:${curr.name?uncap_first}.${field.name?uncap_first}]
                      forKey:${field.owner}WebServiceClientAdapter.${alias(field.name)}];
        }

                    </#if>
                </#if>
            </#if>
        </#list>
    } @catch(NSException *e) {
        NSLog(@"Exception: %@", e);
    }

    return params;
}

- (NSMutableDictionary *) itemIdToJson:(${curr.name?cap_first} *) item {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    @try {
    <#if curr.options.sync??>
        [params setValue:item.serverId
                  forKey:${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}];
    <#else>
        <#list curr_ids as id>
        [params setValue:${FieldsUtils.generateFieldContentType("item", id)}item.${id.name?uncap_first}<#if (FieldsUtils.getObjectiveType(id)?lower_case != "string")>]</#if>
                  forKey:${id.owner}WebServiceClientAdapter.${alias(id.name)}];
        </#list>
    </#if>
    } @catch(NSException *e) {
        NSLog(@"Exception: %@", e);
    }

    return params;
}

- (NSArray *) itemsIdToJson:(NSArray *) items {
    NSMutableArray *itemArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *jsonItems = [NSMutableDictionary dictionary];

    for (int i = 0; i < items.count; i++) {
        jsonItems = [self itemIdToJson:[items objectAtIndex:i]];
        [itemArray addObject:jsonItems];
    }

    return itemArray;
}

- (bool) extract:(NSMutableDictionary *) json
        withItem:(${curr.name} *) item {
    bool result = [self isValidJSON:json];

    if (result) {
    <#if (InheritanceUtils.isExtended(curr))>
        result = [self->motherAdapter extract:json withItem:item];
    <#else>
        <#assign shouldCatch = ((curr.fields?size - curr.relations?size) != 0) />
        <#if shouldCatch>@try {</#if>
            <#list curr.fields?values as field>
                <#if (!field.internal)>
                    <#if (!field.relation??)>
                        <#if (curr.options.sync?? && field.name?lower_case=="id")><#if !InheritanceUtils.isExtended(curr)>
            if (![self jsonIsNull:json withProperty:[${field.owner}WebServiceClientAdapter JSON_MOBILE_ID]]) {
                item.${field.name?uncap_first} = [[json objectForKey:[${curr.name}WebServiceClientAdapter JSON_MOBILE_ID]] intValue];
            }
                        </#if><#elseif (curr.options.sync?? && field.name=="serverId")><#if !InheritanceUtils.isExtended(curr)>
            if (![self jsonIsNull:json withProperty:[${field.owner}WebServiceClientAdapter JSON_ID]]) {
                NSNumber *server_id = [[NSNumberFormatter new]
                                       numberFromString:[json objectForKey:[${field.owner}WebServiceClientAdapter JSON_ID]]];

                if (server_id != 0) {
                    item.serverId = server_id;
                }
            }
                        </#if><#else>

            if (![self jsonIsNull:json withProperty:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]) {
                            <#if (FieldsUtils.getObjectiveType(field)?lower_case == "datetime")>
                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                [dateFormatter <#if (curr.options.sync?? && field.name=="sync_uDate")>setDateFormat:[${field.owner}WebServiceClientAdapter SYNC_UPDATE_DATE_FORMAT<#else>setDateFormat:[${field.owner}WebServiceClientAdapter REST_UPDATE_DATE_FORMAT</#if>]];

                @try {
                    NSDate *date = [dateFormatter dateFromString:[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]];
                    item.${field.name?uncap_first} = date;
                } @catch(NSException* e) {
                    NSLog(@"Exception: %@", e);
                }
                            <#elseif (FieldsUtils.getObjectiveType(field)=="boolean")>
                item.${field.name?uncap_first} = [[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]] boolValue];
                            <#elseif (field.harmony_type == "enum")>
                                <#if enums[field.enum.targetEnum].id??>
                item.${field.name?uncap_first} = [[json objectForKey:[${curr.name}WebServiceClientAdapter ${alias(field.name)}]] ${typeToJsonType(field)}Value];
                                </#if>
                            <#elseif (FieldsUtils.getObjectiveType(field)?lower_case == "int") || (FieldsUtils.getObjectiveType(field)?lower_case == "nsnumber")>
                item.${field.name?uncap_first} = [[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]] intValue];
                            <#elseif (FieldsUtils.getObjectiveType(field)=="long")>
                item.${field.name?uncap_first} = [[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]] longLongValue];
                            <#elseif (FieldsUtils.getObjectiveType(field)=="double")>
                item.${field.name?uncap_first} = [[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]] doubleValue];
                            <#else>
                item.${field.name?uncap_first} = [json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]];
                            </#if>
            }
                         </#if>
                     <#else>
                        <#if (isRestEntity(field.relation.targetEntity))>

            if (![self jsonIsNull:json withProperty:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]) {
                            <#if ((field.relation.type=="OneToMany") || (field.relation.type=="ManyToMany"))>
                NSMutableArray *${field.name?uncap_first} = [NSMutableArray array];
                ${field.relation.targetEntity}WebServiceClientAdapter *${field.name?uncap_first}Adapter = [${field.relation.targetEntity}WebServiceClientAdapter new];
                if ([${field.name?uncap_first}Adapter extractItems:[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]
                                    withItems:${field.name?uncap_first}]) {
                    item.${field.name?uncap_first} = ${field.name?uncap_first};
                }
                            <#elseif ((field.relation.type=="ManyToOne") || (field.relation.type=="OneToOne"))>
                ${field.relation.targetEntity}SQLiteAdapter *${field.relation.targetEntity?uncap_first}SqlAdapter = [${field.relation.targetEntity}SQLiteAdapter new];
                ${field.relation.targetEntity} *${field.relation.targetEntity?uncap_first} = [${field.relation.targetEntity} new];
                ${field.relation.targetEntity}WebServiceClientAdapter *${field.relation.targetEntity?uncap_first}WebService = [${field.relation.targetEntity}WebServiceClientAdapter new];

                [${field.relation.targetEntity?uncap_first}WebService extract:[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]
                                withItem:${field.relation.targetEntity?uncap_first}];
                                <#if (curr.options.sync??)>
                item.${field.name?uncap_first} = [${field.relation.targetEntity?uncap_first}SqlAdapter getByServerID:${field.relation.targetEntity?uncap_first}.serverId];
                                <#else>
                item.${field.name?uncap_first} = ${field.relation.targetEntity?uncap_first};
                                </#if>
                            <#else>
                                <#if (curr.options.sync??)>
                //TODO Sync ${field.relation.type}
                                <#else>

                @try {
                  //TODO ${field.relation.type}
                } @catch (NSException *e) {
                    NSLog(@"Exception %@", @"Json doesn't contains ${field.relation.targetEntity} data");
                }
                                </#if>
                            </#if>
            }
                    </#if>
                </#if>
            </#if>
        </#list>
        <#if shouldCatch>} @catch (NSException *e) {
            NSLog(@"Exception %@", e);
        }</#if>
    </#if>
    }

    return result;
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
            ${curr.name} *item = [${curr.name} new];

            [self extract:[NSMutableDictionary dictionaryWithDictionary:jsonItem] withItem:item];

            if (item != nil) {
                [items addObject:item];
            }
        }

        result = (int) items.count;
    }

    return result;
}

- (int) get:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback {
    int result = -1;

    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {
        NSLog(@"Convert to item ${curr.name}.");

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];
            
            if ([self isValidJSON:json]) {
                [self extract:json withItem:${curr.name?uncap_first}];
            }
        }

        if (callback != nil) {
            callback(${curr.name?uncap_first});
        }
    };

    [self invokeRequest:GET
            withRequest:[NSString stringWithFormat:@"%@<#if (curr.options.sync??)>/%@<#else><#list curr_ids as id>/%@</#list></#if>%@",
                         [self getUri],
                         <#if (curr.options.sync??)>${curr.name?uncap_first}.serverId,<#else><#list curr_ids as id>[NSNumber numberWithInt:${curr.name?uncap_first}.${id.name}],</#list></#if>
                         [${curr.name}WebServiceClientAdapter REST_FORMAT]]
             withParams:nil
           withCallback:restCallback];

    return result;
}

- (int) getAll:(void(^)(NSArray *)) callback {
    int result = -1;

    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {
        NSLog(@"Convert to item ${curr.name}.");
        NSMutableArray *items = [NSMutableArray new];

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];

            if ([self isValidJSON:json]) {
                [self extractItems:[json objectForKey:@"${curr.name?cap_first}s"] withItems:items];
            }
        }

        if (callback != nil) {
            callback(items);
        }
    };

    [self invokeRequest:GET
            withRequest:[NSString stringWithFormat:@"%@%@",
                         [self getUri],
                         [${curr.name}WebServiceClientAdapter REST_FORMAT]]
             withParams:nil
           withCallback:restCallback];

    return result;
}

- (int) update:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback {
    int result = -1;

    void (^restCallback)(HttpResponse *) = ^(HttpResponse *object) {
        NSLog(@"Convert to item ${curr.name}.");

        if (object.result != nil) {
            NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) object.result];

            if ([self isValidJSON:json]) {
                [self extract:json withItem:${curr.name?uncap_first}];
            }
        }

        if (callback != nil) {
            callback(${curr.name?uncap_first});
        }
    };

    [self invokeRequest:PUT
            withRequest:[NSString stringWithFormat:@"%@<#if (curr.options.sync??)>/%@<#else><#list curr_ids as id>/%@</#list></#if>%@",
                         [self getUri],
                         <#if (curr.options.sync??)>${curr.name?uncap_first}.serverId,<#else><#list curr_ids as id>[NSNumber numberWithInt:${curr.name?uncap_first}.${id.name}],</#list></#if>
                         [${curr.name}WebServiceClientAdapter REST_FORMAT]]
             withParams:[self itemToJson:${curr.name?uncap_first}]
           withCallback:restCallback];

    return result;
}

- (int) insert:(${curr.name}*) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback {
    int result = -1;

    void ( ^restCallback )( HttpResponse* ) = ^(HttpResponse* object) {
        NSLog(@"Convert to item ${curr.name}.");

        if (object.result != nil) {
            NSMutableDictionary* json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*) object.result];

            if ([self isValidJSON:json]) {
                [self extract:json withItem:${curr.name?uncap_first}];
            }
        }

        if (callback != nil) {
            callback(${curr.name?uncap_first});
        }
    };

    [self invokeRequest:POST
            withRequest:[NSString stringWithFormat:@"%@%@",
                         [self getUri],
                         [${curr.name}WebServiceClientAdapter REST_FORMAT]]
             withParams:[self itemToJson:${curr.name?uncap_first}]
           withCallback:restCallback];

    return result;
}

@end
