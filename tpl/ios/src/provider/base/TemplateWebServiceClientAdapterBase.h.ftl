<@header?interpret />
<#include utilityPath + "all_imports.ftl" />
<#assign curr = entities[current_entity] />
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
<#function alias name object=false>
    <#if object>
        <#return "JSON_OBJECT_"+name?upper_case />
    <#else>
        <#return "JSON_"+name?upper_case />
    </#if>
</#function>
#import "WebServiceClientAdapter.h"
#import "${curr.name}.h"
<#assign import_array = [curr.name] />
<#assign alreadyImportArrayList=false />
<#list curr.relations as relation>
    <#if (isRestEntity(relation.relation.targetEntity))>
        <#if (!isInArray(import_array, relation.relation.targetEntity))>
            <#assign import_array = import_array + [relation.relation.targetEntity] />
@class ${relation.relation.targetEntity}WebServiceClientAdapter;
        </#if>
    </#if>
</#list>
<#if (InheritanceUtils.isExtended(curr))>
#import "${curr.inheritance.superclass.name}WebServiceClientAdapter.h"
</#if>
<#if (curr.options.sync??)>#import "SyncClientAdapterBase.h"</#if>

/**
 *
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony.
 * You should edit ${curr.name}WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@interface ${curr.name}WebServiceClientAdapterBase : <#if (curr.options.sync??)>SyncClientAdapterBase<#else>WebServiceClientAdapter</#if> <#if (InheritanceUtils.isExtended(curr))>{

@protected
    ${curr.inheritance.superclass.name}WebServiceClientAdapter* motherAdapter;
}
</#if>

<#if (curr.options.sync??)>
/** JSON mobile id. */
+ (NSString *) JSON_MOBILE_ID;
/** Sync Date Format pattern. */
+ (NSString *) SYNC_UPDATE_DATE_FORMAT;
</#if>

/** Rest Date Format pattern. */
+ (NSString *) REST_UPDATE_DATE_FORMAT;

/** JSON Object ${curr.name} pattern. */
+ (NSString *) ${alias(curr.name, true)};
    <#list curr.fields?values as field>
        <#if (!field.internal)>
            <#if (!field.relation??) || (isRestEntity(field.relation.targetEntity))>
/** ${alias(field.name)} attributes. */
+ (NSString *) ${alias(field.name)};
            </#if>
        </#if>
    </#list>

/**
 * Extract a list of ${curr.name} from a JSONObject describing an array of ${curr.name} given the array name
 * @param json The JSONObject describing the array of <T>
 * @param items The returned list of <T>
 * @return The number of <T> found in the JSON
 */
- (int) extractItems:(NSArray *) jsonArray
           withItems:(NSMutableArray *) items;

/**
 * Extract a ${curr.name} from a JSONObject describing a ${curr.name}
 * @param json The JSONObject describing the ${curr.name}
 * @param item The returned ${curr.name}
 * @return true if a ${curr.name} was found. false if not
 */
- (bool) extract:(NSMutableDictionary *) json
        withItem:(${curr.name} *) item;

/**
 * Convert a ${curr.name} to a JSONObject.
 * @param bestRating The ${curr.name} to convert
 * @return The converted ${curr.name}
 */
- (NSMutableDictionary *) itemToJson:(${curr.name?cap_first} *) ${curr.name?uncap_first};

/**
 * Convert a <T> to a NSMutableDictionary.
 * @param item The <T> to convert
 * @return The converted <T>
 */
- (NSMutableDictionary *) itemIdToJson:(${curr.name?cap_first} *) item;

/**
 * Convert a list of <${curr.name}> to a NSMutableDictionary.
 * @param users The array of <${curr.name}> to convert
 * @return The array of converted <${curr.name}>
 */
- (NSArray *) itemsIdToJson:(NSArray *) items;

/**
 * Get the id of the current <${curr.name}>.
 * @return Index of <${curr.name}>
 */
- (int) getItemId:(${curr.name} *) item;

/**
 * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the ID)
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) get:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback;

/**
 * Retrieve all the ${curr.name}s in the given list. Uses the route : ${curr.options.rest.uri}.
 * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
 * @return The number of ${curr.name}s returned
 */
- (int) getAll:(void(^)(NSArray *)) callback;

/**
 * Update a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to update
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) update:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback;

/**
 * Insert a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to insert
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) insert:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(${curr.name} *)) callback;

/**
 * Delete a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to delete
 * @return -1 if an error has occurred. 0 if not.
 */
- (void) remove:(${curr.name} *) ${curr.name?uncap_first} withCallback:(void(^)(int)) callback;

@end
