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
#import "WebServiceClientAdapter.h"
#import "${curr.name}.h"
<#assign import_array = [curr.name] />
<#assign alreadyImportArrayList=false />
<#list curr.relations as relation>
    <#if (isRestEntity(relation.relation.targetEntity))>
        <#if (!isInArray(import_array, relation.relation.targetEntity))>
            <#assign import_array = import_array + [relation.relation.targetEntity] />
#import "${relation.relation.targetEntity}WebServiceClientAdapter.h"
        </#if>
    </#if>
</#list>

/**
 * 
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony. 
 * You should edit ${curr.name}WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@interface ${curr.name}WebServiceClientAdapterBase : WebServiceClientAdapter {

    /** Rest Date Format pattern. */
+    (NSString *) REST_UPDATE_DATE_FORMAT;
    
    /** JSON Object ${curr.name} pattern. */
+    (NSString *) ${alias(curr.name, true)};
    <#list curr.fields?values as field>
        <#if (!field.internal)>
            <#if (!field.relation??) || (isRestEntity(field.relation.targetEntity))>
    /** ${alias(field.name)} attributes. */
+    (NSString *) ${alias(field.name)};
            </#if>
        </#if>
    </#list>
    <#if (curr.options.sync??)>
@protected
    ${curr.inheritance.superclass.name}WebServiceClientAdapter* motherAdapter;
}
    </#if>
/**
 * Extract a list of ${curr.name} from a JSONObject describing an array of ${curr.name} given the array name
 * @param json The JSONObject describing the array of <T>
 * @param items The returned list of <T>
 * @param paramName The name of the array
 * @return The number of <T> found in the JSON
 */
- (int) extractItems:(NSArray*) jsonArray
          withItems:(NSMutableArray*) items;

/**
 * Extract a ${curr.name} from a JSONObject describing a ${curr.name}
 * @param json The JSONObject describing the ${curr.name}
 * @param item The returned ${curr.name}
 * @return true if a ${curr.name} was found. false if not
 */
- (BOOL) extract:(NSDictionary*) json
       withItem:(${curr.name}*) item;

/**
 * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the ID)
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) get:(${curr.name}*) ${curr.name?uncap_first};

/**
 * Retrieve all the ${curr.name}s in the given list. Uses the route : ${curr.options.rest.uri}.
 * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
 * @return The number of ${curr.name}s returned
 */
- (int) getAll:(NSArray*) ${curr.name?uncap_first}s;

/**
 * Update a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to update
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) update:(${curr.name}*) ${curr.name?uncap_first};

/**
 * Insert a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
 * @param ${curr.name?uncap_first} : The ${curr.name} to insert
 * @return -1 if an error has occurred. 0 if not.
 */
- (int) insert:(${curr.name}*) ${curr.name?uncap_first};

@end
