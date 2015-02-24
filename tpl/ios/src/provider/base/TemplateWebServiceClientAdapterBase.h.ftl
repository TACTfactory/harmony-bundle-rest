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
        <#switch FieldsUtils.getJavaType(field)?lower_case>
            <#case "int">
                <#return "Int" />
                <#break />
            <#case "float">
                <#return "Float" />
                <#break />
            <#case "double">
                <#return "Double" />
                <#break />
            <#case "long">
                <#return "Long" />
                <#break />
            <#case "boolean">
                <#return "Boolean" />
                <#break />
            <#case "enum">
                <#assign enumType = enums[field.enum.targetEnum] />
                <#if enumType.id??>
                    <#assign idEnumType = enumType.fields[enumType.id].harmony_type?lower_case />
                    <#if (idEnumType == "int") >
                        <#return "Int" />
                    <#else>
                        <#return "String" />
                    </#if>
                <#else>
                    <#return "String" />
                </#if>
                <#break />
            <#default>
                <#return "String" />
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
//${ImportUtils.importRelatedEnums(curr)}

/**
 * 
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony. 
 * You should edit ${curr.name}WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
@interface ${curr.name}WebServiceClientAdapterBase : WebServiceClientAdapter {

    /** JSON Object ${curr.name} pattern. */
    (NSString *) ${alias(curr.name, true)};
    <#list curr.fields?values as field>
        <#if (!field.internal)>
            <#if (!field.relation??) || (isRestEntity(field.relation.targetEntity))>
    /** ${alias(field.name)} attributes. */
    (NSString *) ${alias(field.name)};
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
