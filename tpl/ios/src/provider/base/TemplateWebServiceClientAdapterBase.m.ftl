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
    <#if (isRestEntity(relation.relation.targetEntity)012
0        </#if>
    </#list>
    <#if (curr.options.sync??)>
    /** Sync Date Format pattern. */
+   (NSString *) SYNC_UPDATE_DATE_FORMAT        { return @"${curr.options.sync.updateDateFormatJava}"; }
    </#if>

    /** Rest Date Format pattern. */
+   (NSString *) REST_UPDATE_DATE_FORMAT        { return @"${curr.options.rest.dateFormat}"; }

    <#if (InheritanceUtils.isExtended(curr))>
- (id) init {
    if (self = [super init]) {
        self->motherAdapter = [${curr.inheritance.superclass.name}WebServiceClientAdapter new];
    }
    
    return self;
}
    </#if>

/*
- (BOOL) isValidJSON:(NSObject *)json {
    return ![self jsonIsNull:(NSDictionary*) json
                withProperty:[${curr.name}WebServiceClientAdapter JSON_ID]];
}
*/
- (int) extractItems:(NSArray*) jsonArray
          withItems:(NSMutableArray*) items {
    
    for (NSDictionary* json in jsonArray) {
        ${curr.name}* item = [${curr.name} new];
        
        if ([self extract:json withItem:item]) {
            [items addObject:item];
        }
    }
    
    return items.count;
}

- (BOOL) extract:(NSDictionary *)json
       withItem:(${curr.name} *)item {
    
    BOOL result = [self isValidJSON:json];
    if (result) {
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
                item.${field.name?uncap_first} = [[json objectForKey:[${curr.name}WebServiceClientAdapter JSON_ID]] intValue];
            }
            
                        </#if><#else>
                        
            if (![self jsonIsNull:json withProperty:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]) {
                            <#if (FieldsUtils.getObjectiveType(field)?lower_case == "datetime")>
                NSDateFormatter* dateFormatter = [NSDateFormatter new];
                [dateFormatter <#if (curr.options.sync?? && field.name=="sync_uDate")>setDateFormat:[
                ${field.owner}WebServiceClientAdapter SYNC_UPDATE_DATE_FORMAT<#else>setDateFormat:[
                ${field.owner}WebServiceClientAdapter REST_UPDATE_DATE_FORMAT</#if>]];

                @try {
                    NSDate* date = [dateFormatter dateFromString:
                                    [json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]];
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
                            <#elseif (FieldsUtils.getObjectiveType(field)=="int") || (FieldsUtils.getObjectiveType(field)=="integer")>
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
                NSMutableArray* ${field.name?uncap_first} = [NSMutableArray array];
                ${field.relation.targetEntity}WebServiceClientAdapter* ${field.name?uncap_first}Adapter =
                        [${field.relation.targetEntity}WebServiceClientAdapter new];
                if ([${field.name?uncap_first}Adapter extractItems:[json objectForKey:[${field.owner}WebServiceClientAdapter ${alias(field.name)}]]
                                     withItems:${field.name?uncap_first}]) {
                    item.${field.name?uncap_first} = ${field.name?uncap_first};
                }
                        <#else>
                            <#if (curr.options.sync??)>
                    //TODO Sync ${field.relation.type}
                            <#else>

                    @try {
                      //TODO ${field.relation.type}
                    } @catch (NSException *e) {
                        NSLog(@"Exception %@", "Json doesn't contains ${field.relation.targetEntity} data");
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
    }
}

- (int) get:(${curr.name}*) ${curr.name?uncap_first} {
    //TODO Get ${curr.name}
	return 0;
}

- (int) getAll:(NSArray*) ${curr.name?uncap_first}s {
    //TODO Get All ${curr.name}
	return 0;
}

- (int) update:(${curr.name}*) ${curr.name?uncap_first} {
    //TODO Update ${curr.name}
	return 0;
}

- (int) insert:(${curr.name}*) ${curr.name?uncap_first} {
    //TODO Insert ${curr.name}
	return 0;
}

@end
