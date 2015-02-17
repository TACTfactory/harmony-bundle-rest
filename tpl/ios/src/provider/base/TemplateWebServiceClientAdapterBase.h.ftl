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
<#function extract field>
    <#if (!field.internal)>
        <#if (field.harmony_type?lower_case != "relation")>
            <#switch FieldsUtils.getJavaType(field)?lower_case>
                <#case "datetime">
        DateTimeFormatter ${field.name?uncap_first}Formatter = ${getFormatter(field)};
        ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first}Formatter.parseDateTime(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().toString())));
                    <#break />
                <#case "boolean">
        ${curr.name?uncap_first}.set${field.name?cap_first}(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.is${field.name?cap_first}()));    
                    <#break />
                <#default>
        ${curr.name?uncap_first}.set${field.name?cap_first}(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}()));    
                    <#break />
            </#switch>
        <#else>
            <#if (isRestEntity(field.relation.targetEntity))>
                <#if (field.relation.type=="OneToMany" || field.relation.type=="ManyToMany")>
        ArrayList<${field.relation.targetEntity}> ${field.name?uncap_first} = new ArrayList<${field.relation.targetEntity}>();
        try {
        ${field.relation.targetEntity}WebServiceClientAdapter.extract${field.relation.targetEntity}s(json.opt${typeToJsonType(field)}(${alias(field.name)}), ${field.name?uncap_first});
        ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
        } catch (JSONException e) {
        Log.e(TAG, e.getMessage());
        }
                <#else>
        ${field.relation.targetEntity} ${field.name?uncap_first} = new ${field.relation.targetEntity}();
        ${field.relation.targetEntity}WebServiceClientAdapter.extract(json.opt${typeToJsonType(field)}(${alias(field.name)}), ${field.name?uncap_first});
        ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
                </#if>
            </#if>
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
@interface ${curr.name}WebServiceClientAdapterBase : ${extends} {

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

@end
