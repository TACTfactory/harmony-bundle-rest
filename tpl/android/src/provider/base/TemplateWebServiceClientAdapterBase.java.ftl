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
            <#case "short">
                <#return "Int" />
                <#break />
            <#case "byte">
            <#case "char">
            <#case "Character">
                <#return "String" />
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
package ${curr.data_namespace}.base;

import java.util.List;
<#if (MetadataUtils.hasToManyRelations(curr) || curr.options.sync??)>import java.util.ArrayList;</#if>

<#assign importDate = false />
<#list curr.fields?values as field>
    <#if !importDate && (FieldsUtils.getJavaType(field)?lower_case == "datetime")>
import org.joda.time.format.DateTimeFormatter;
import ${curr.namespace}.harmony.util.DateUtils;
        <#assign importDate = true />
    </#if>
</#list>
import org.joda.time.DateTime;
import org.joda.time.format.ISODateTimeFormat;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;

import ${data_namespace}.*;
import ${curr.namespace}.entity.${curr.name};
import ${data_namespace}.RestClient.Verb;
import ${project_namespace}.provider.contract.${curr.name?cap_first}Contract;
<#if InheritanceUtils.isExtended(curr)>import ${project_namespace}.provider.contract.${curr.inheritance.superclass.name?cap_first}Contract;</#if>
<#assign import_array = [curr.name] />
<#assign alreadyImportArrayList=false />
<#list curr.relations as relation>
    <#if (isRestEntity(relation.relation.targetEntity))>
        <#if (!isInArray(import_array, relation.relation.targetEntity))>
            <#assign import_array = import_array + [relation.relation.targetEntity] />
import ${curr.namespace}.entity.${relation.relation.targetEntity};
        </#if>
    </#if>
</#list>
${ImportUtils.importRelatedEnums(curr)}
<#if (curr.options.sync??)>
import ${curr.namespace}.entity.base.EntityBase;
</#if>

<#if (curr.options.sync??)>
    <#assign extends="SyncClientAdapterBase<${curr.name?cap_first}>" />
<#else>
    <#assign extends="WebServiceClientAdapter<${curr.name?cap_first}>" />
</#if>
/**
 *
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony.
 * You should edit ${curr.name}WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 *
 */
public abstract class ${curr.name}WebServiceClientAdapterBase
        extends ${extends} {
    /** ${curr.name}WebServiceClientAdapterBase TAG. */
    protected static final String TAG = "${curr.name}WSClientAdapter";

    /** JSON Object ${curr.name} pattern. */
    protected static String ${alias(curr.name, true)} = "${curr.name}";
    <#list curr.fields?values as field>
        <#if (!field.internal)>
            <#if (!field.relation??) || (isRestEntity(field.relation.targetEntity))>
    /** ${alias(field.name)} attributes. */
                <#if field.options.rest?? && field.options.rest.name != "" >
    protected static String ${alias(field.name)} = "${field.options.rest.name}";
                <#else>
    protected static String ${alias(field.name)} = "${field.name?uncap_first}";
                </#if>
            </#if>
        </#if>
    </#list>
    <#if (curr.options.sync??)>
    /** JSON mobile id. */
    protected static String JSON_MOBILE_ID = "mobile_id";

    /** Sync Date Format pattern. */
    public static final String SYNC_UPDATE_DATE_FORMAT = "${curr.options.sync.updateDateFormatJava}";
    </#if>

    /** Rest Date Format pattern. */
    public static final String REST_UPDATE_DATE_FORMAT = "${curr.options.rest.dateFormat}";

    /** ${curr.name} REST Columns. */
    public static String[] REST_COLS = new String[]{
            <#list restFields as field>
                <#list ContractUtils.getFieldsNames(field) as refId>
            ${refId}<#if field_has_next || refId_has_next>,</#if>
                </#list>
            </#list>
        };
    <#if (InheritanceUtils.isExtended(curr))>

    protected ${curr.inheritance.superclass.name}WebServiceClientAdapter motherAdapter;
    </#if>

    /**
     * Constructor with overriden port and host.
     *
     * @param context The context
     */
    public ${curr.name}WebServiceClientAdapterBase(Context context) {
        this(context, null);
    }

    /**
     * Constructor with overriden port.
     *
     * @param context The context
     * @param port The overriden port
     */
    public ${curr.name}WebServiceClientAdapterBase(Context context,
        Integer port) {
        this(context, null, port);
    }

    /**
     * Constructor with overriden port and host.
     *
     * @param context The context
     * @param host The overriden host
     * @param port The overriden port
     */
    public ${curr.name}WebServiceClientAdapterBase(Context context,
            String host, Integer port) {
        this(context, host, port, null);
    }

    /**
     * Constructor with overriden port, host and scheme.
     *
     * @param context The context
     * @param host The overriden host
     * @param port The overriden port
     * @param scheme The overriden scheme
     */
    public ${curr.name}WebServiceClientAdapterBase(Context context,
            String host, Integer port, String scheme) {
        this(context, host, port, scheme, null);
    }

    /**
     * Constructor with overriden port, host, scheme and prefix.
     *
     * @param context The context
     * @param host The overriden host
     * @param port The overriden port
     * @param scheme The overriden scheme
     * @param prefix The overriden prefix
     */
    public ${curr.name}WebServiceClientAdapterBase(Context context,
            String host, Integer port, String scheme, String prefix) {
        super(context, host, port, scheme, prefix);
        <#if (InheritanceUtils.isExtended(curr))>
        this.motherAdapter =
            new ${curr.inheritance.superclass.name}WebServiceClientAdapter(
                context, host, port, scheme, prefix);
        </#if>
    }

    /**
     * Retrieve all the ${curr.name}s in the given list. Uses the route : ${curr.options.rest.uri}.
     * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
     * @return The number of ${curr.name}s returned
     */
    public int getAll(List<${curr.name}> ${curr.name?uncap_first}s) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.GET,
                    String.format(
                        this.getUri() + "%s",
                        REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            try {
                JSONObject json = new JSONObject(response);
                result = extractItems(json, "${curr.name?cap_first}s", ${curr.name?uncap_first}s);
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                ${curr.name?uncap_first}s = null;
            }
        }

        return result;
    }

    /**
     * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
     * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the ID)
     * @return -1 if an error has occurred. 0 if not.
     */
    public int get(${curr.name} ${curr.name?uncap_first}) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.GET,
                    String.format(
                        this.getUri() + "<#list IdsUtils.getAllIdsGetters(curr) as id>/%s</#list>%s",
                        <#list IdsUtils.getAllIdsGetters(curr) as id><#if (curr.options.sync??)>${curr.name?uncap_first}.getServerId()<#else>${curr.name?uncap_first}${id}</#if>,
                        </#list>REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            try {
                JSONObject json = new JSONObject(response);
                if (extract(json, ${curr.name?uncap_first})) {
                    result = 0;
                }
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                ${curr.name?uncap_first} = null;
            }
        }

        return result;
    }

    /**
     * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
     * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the <#if (curr.options.sync??)>server</#if> ID)
     * @return -1 if an error has occurred. 0 if not.
     */
    public Cursor query(<#list curr_ids as id>final ${FieldsUtils.getJavaType(id)} <#if (curr.options.sync??)>server${id.name?cap_first}<#else>${id.name}</#if><#if (id_has_next)>,
            </#if></#list>) {
        MatrixCursor result = new MatrixCursor(REST_COLS);
        String response = this.invokeRequest(
                    Verb.GET,
                    String.format(
                        this.getUri() + "<#list curr_ids as id>/%s</#list>%s",
                        <#list curr_ids as id><#if (curr.options.sync??)>server${id.name?cap_first}<#else>${id.name}</#if>,
                        </#list>REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            try {
                JSONObject json = new JSONObject(response);
                this.extractCursor(json, result);
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                result = null;
            }
        }

        return result;
    }

    /**
     * @return the URI.
     */
    public String getUri() {
        return "${curr.options.rest.uri}";
    }

    /**
     * Update a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
     * @param ${curr.name?uncap_first} : The ${curr.name} to update
     * @return -1 if an error has occurred. 0 if not.
     */
    public int update(${curr.name} ${curr.name?uncap_first}) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.PUT,
                    String.format(
                        this.getUri() + "<#list IdsUtils.getAllIdsGetters(curr) as id>/%s</#list>%s",
                        <#list IdsUtils.getAllIdsGetters(curr) as id><#if (curr.options.sync??)>${curr.name?uncap_first}.getServerId()<#else>${curr.name?uncap_first}${id}</#if>,
                        </#list>REST_FORMAT),
                    itemToJson(${curr.name?uncap_first}));

        if (this.isValidResponse(response) && this.isValidRequest()) {
            result = 0;
        }

        return result;
    }

    /**
     * Delete a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%.
     * @param ${curr.name?uncap_first} : The ${curr.name} to delete (only the id is necessary)
     * @return -1 if an error has occurred. 0 if not.
     */
    public int delete(${curr.name} ${curr.name?uncap_first}) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.DELETE,
                    String.format(
                        this.getUri() + "<#list IdsUtils.getAllIdsGetters(curr) as id>/%s</#list>%s",
                        <#list IdsUtils.getAllIdsGetters(curr) as id><#if (curr.options.sync??)>${curr.name?uncap_first}.getServerId()<#else>${curr.name?uncap_first}${id}</#if>,
                        </#list>REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            result = 0;
        }

        return result;
    }

    <#list curr.relations as relation>
        <#if (isRestEntity(relation.relation.targetEntity))>
            <#if (relation.relation.type=="OneToMany")>

            <#elseif (relation.relation.type=="ManyToMany" || relation.relation.type=="ManyToOne")>
    /**
     * Get the ${curr.name}s associated with a ${relation.relation.targetEntity}. Uses the route : ${entities[relation.relation.targetEntity].options.rest.uri?lower_case}/%${relation.relation.targetEntity}_id%/${curr.options.rest.uri?lower_case}.
     * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
     * @param ${relation.relation.targetEntity?lower_case} : The associated ${relation.relation.targetEntity?lower_case}
     * @return The number of ${curr.name}s returned
     */
    public int getBy${relation.name?cap_first}(List<${curr.name}> ${curr.name?uncap_first}s, ${relation.relation.targetEntity} ${relation.relation.targetEntity?uncap_first}) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.GET,
                    String.format(
                        this.getUri() + "<#list IdsUtils.getAllIdsGetters(entities[relation.relation.targetEntity]) as id>/%s</#list>%s",
                        <#list IdsUtils.getAllIdsGetters(entities[relation.relation.targetEntity]) as id><#if (curr.options.sync??)>${relation.relation.targetEntity?uncap_first}.getServerId()<#else>${relation.relation.targetEntity?uncap_first}${id}</#if>,
                        </#list>REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            try {
                JSONObject json = new JSONObject(response);
                result = this.extractItems(json, "${curr.name?cap_first}s", ${curr.name?uncap_first}s);
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                ${curr.name?uncap_first}s = null;
            }
        }

        return result;
    }

            <#else>
    /**
     * Get the ${curr.name} associated with a ${relation.relation.targetEntity}. Uses the route : ${entities[relation.relation.targetEntity].options.rest.uri?lower_case}/%${relation.relation.targetEntity}_id%/${curr.options.rest.uri?lower_case}.
     * @param ${curr.name?uncap_first} : The ${curr.name} that will be returned
     * @param ${relation.relation.targetEntity?lower_case} : The associated ${relation.relation.targetEntity?lower_case}
     * @return -1 if an error has occurred. 0 if not.
     */
    public int getBy${relation.relation.targetEntity}(${curr.name} ${curr.name?uncap_first}, ${relation.relation.targetEntity} ${relation.relation.targetEntity?uncap_first}) {
        int result = -1;
        String response = this.invokeRequest(
                    Verb.GET,
                    String.format(
                        this.getUri() + "<#list IdsUtils.getAllIdsGetters(entities[relation.relation.targetEntity]) as id>/%s</#list>%s",
                        <#list IdsUtils.getAllIdsGetters(entities[relation.relation.targetEntity]) as id><#if (curr.options.sync??)>${relation.relation.targetEntity?uncap_first}.getServerId()<#else>${relation.relation.targetEntity?uncap_first}${id}</#if>,
                        </#list>REST_FORMAT),
                    null);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            try {
                JSONObject json = new JSONObject(response);
                this.extract(json, ${curr.name?uncap_first});
                result = 0;
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
                ${curr.name?uncap_first} = null;
            }
        }

        return result;
    }

            </#if>
        </#if>
    </#list>

    /**
     * Tests if the json is a valid ${curr.name} Object.
     *
     * @param json The json
     *
     * @return True if valid
     */
    public boolean isValidJSON(JSONObject json) {
        boolean result = true;
        <#list IdsUtils.getAllIdsNamesFromArray(curr.ids) as id>
        result = result && json.has(${curr.ids[0].owner}WebServiceClientAdapter.${alias(id)});
        </#list>

        return result;
    }

    /**
     * Extract a ${curr.name} from a JSONObject describing a ${curr.name}.
     * @param json The JSONObject describing the ${curr.name}
     * @param ${curr.name?uncap_first} The returned ${curr.name}
     * @return true if a ${curr.name} was found. false if not
     */
    public boolean extract(JSONObject json, ${curr.name} ${curr.name?uncap_first}) {
        <#assign shouldCatch = ((curr.fields?size - curr.relations?size) != 0) />
        boolean result = this.isValidJSON(json);
        <#if (InheritanceUtils.isExtended(curr))>
        this.motherAdapter.extract(json, ${curr.name?uncap_first});
        </#if>
        if (result) {
            <#if shouldCatch>try {</#if>
            <#list curr.fields?values as field>
                <#if (!field.internal)>
                    <#if (!field.relation??)>
                        <#if (curr.options.sync?? && field.name?lower_case=="id")><#if !InheritanceUtils.isExtended(curr)>
                if (json.has(${field.owner}WebServiceClientAdapter.JSON_MOBILE_ID)
                        && !json.isNull(${field.owner}WebServiceClientAdapter.JSON_MOBILE_ID)) {
                    ${curr.name?uncap_first}.setId(json.getInt(
                               ${field.owner}WebServiceClientAdapter.JSON_MOBILE_ID));
                }
                        </#if><#elseif (curr.options.sync?? && field.name=="serverId")><#if !InheritanceUtils.isExtended(curr)>
                if (json.has(${field.owner}WebServiceClientAdapter.JSON_ID)) {
                    int server_id = json.optInt(
                              ${curr.name}WebServiceClientAdapter.JSON_ID);

                    if (server_id != 0) {
                        ${curr.name?uncap_first}.setServerId(server_id);
                    }
                }
                        </#if><#elseif (curr.options.sync?? && field.name=="hash")><#if !InheritanceUtils.isExtended(curr)>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));
                        </#if><#else>

                if (json.has(${field.owner}WebServiceClientAdapter.${alias(field.name)})
                        && !json.isNull(${field.owner}WebServiceClientAdapter.${alias(field.name)})) {
                            <#if (FieldsUtils.getJavaType(field)?lower_case == "datetime")>
                    DateTimeFormatter ${field.name?uncap_first}Formatter = <#if (curr.options.sync?? && field.name=="sync_uDate")>DateTimeFormat.forPattern(
                            ${field.owner}WebServiceClientAdapter.SYNC_UPDATE_DATE_FORMAT)<#else>DateTimeFormat.forPattern(
                            ${field.owner}WebServiceClientAdapter.REST_UPDATE_DATE_FORMAT)</#if>;
                    try {
                        ${curr.name?uncap_first}.set${field.name?cap_first}(
                                ${field.name?uncap_first}Formatter.withOffsetParsed().parseDateTime(
                                        json.get${typeToJsonType(field)}(
                                        ${field.owner}WebServiceClientAdapter.${alias(field.name)})));
                    } catch (IllegalArgumentException e) {
                        Log.e(TAG, e.getMessage());
                    }
                            <#elseif (FieldsUtils.getJavaType(field)=="boolean")>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));
                            <#elseif (field.harmony_type == "enum")>
                                <#if enums[field.enum.targetEnum].id??>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(${field.enum.targetEnum}.fromValue(json.get${typeToJsonType(field)}(
                                ${field.owner}WebServiceClientAdapter.${alias(field.name)})));
                                <#else>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(${field.enum.targetEnum}.valueOf(json.get${typeToJsonType(field)}(
                                    ${field.owner}WebServiceClientAdapter.${alias(field.name)})));
                                </#if>
                            <#elseif (field.harmony_type == "byte")>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(Byte.valueOf(
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)})));
                            <#elseif (field.harmony_type == "short")>
                    ${curr.name?uncap_first}.set${field.name?cap_first}((short)
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));
                            <#elseif (field.harmony_type == "char") || (field.harmony_type == "Character")>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}).charAt(0));
                            <#else>
                    ${curr.name?uncap_first}.set${field.name?cap_first}(
                            json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));
                            </#if>
                }
                        </#if>
                    <#else>
                        <#if (isRestEntity(field.relation.targetEntity))>

                if (json.has(${field.owner}WebServiceClientAdapter.${alias(field.name)})
                        && !json.isNull(${field.owner}WebServiceClientAdapter.${alias(field.name)})) {
                            <#if (field.relation.type=="OneToMany" || field.relation.type=="ManyToMany")>
                    ArrayList<${field.relation.targetEntity}> ${field.name?uncap_first} =
                            new ArrayList<${field.relation.targetEntity}>();
                    ${field.relation.targetEntity}WebServiceClientAdapter ${field.name}Adapter =
                            new ${field.relation.targetEntity}WebServiceClientAdapter(this.context);

                    try {
                        //.opt${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)});
                        ${field.name}Adapter.extractItems(
                                json, ${field.owner}WebServiceClientAdapter.${alias(field.name)},
                                ${field.name?uncap_first});
                        ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
                    } catch (JSONException e) {
                        Log.e(TAG, e.getMessage());
                    }
                            <#else>
                                <#if (curr.options.sync??)>
                    ${field.relation.targetEntity}SQLiteAdapter ${field.name}Adapter =
                            new ${field.relation.targetEntity}SQLiteAdapter(this.context);
                    ${field.name}Adapter.open();
                    ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name}Adapter.getByServerID(
                            json.optJSONObject(${field.owner}WebServiceClientAdapter.JSON_${field.name?upper_case}).optInt(JSON_ID)));
                    ${field.name}Adapter.close();
                                <#else>

                    try {
                        ${field.relation.targetEntity}WebServiceClientAdapter ${field.name}Adapter =
                                new ${field.relation.targetEntity}WebServiceClientAdapter(this.context);
                        ${field.relation.targetEntity} ${field.name?uncap_first} =
                                new ${field.relation.targetEntity}();

                        if (${field.name}Adapter.extract(
                                json.opt${typeToJsonType(field)}(
                                        ${field.owner}WebServiceClientAdapter.${alias(field.name)}),
                                        ${field.name?uncap_first})) {
                            ${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "Json doesn't contains ${field.relation.targetEntity} data");
                    }
                                </#if>
                            </#if>
                }
                        </#if>
                    </#if>
                </#if>
            </#list>
            <#if shouldCatch>} catch (JSONException e) {
                Log.e(TAG, e.getMessage());
            }</#if>
        }

        return result;
    }

    @Override
    public boolean extractCursor(JSONObject json, MatrixCursor cursor) {
        boolean result = false;
        String id = json.optString(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, null);
        if (id != null) {
            try {
            <#assign restFieldsSize = 0 />
            <#list restFields as field><#if field.relation??><#assign restFieldsSize = restFieldsSize + field.relation.field_ref?size /><#else><#assign restFieldsSize = restFieldsSize + 1 /></#if></#list>
                String[] row = new String[${restFieldsSize}];
            <#assign i = 0 />
            <#list restFields as field>
                <#assign jsonAlias = field.owner + "WebServiceClientAdapter." + alias(field.name)/>
                <#if field.relation??>
                if (json.has(${jsonAlias})) {
                    JSONObject ${field.name}Json = json.getJSONObject(
                            ${jsonAlias});
                    <#list field.relation.field_ref as refId>
                    row[${i}] = ${field.name}Json.getString(
                            ${refId.owner}WebServiceClientAdapter.${alias(refId.name)});
                        <#assign i = i + 1 />
                    </#list>
                }
                <#else>
                    <#assign jsonAlias = jsonAlias />
                if (json.has(${jsonAlias})) {
                    row[${i}] = json.getString(${jsonAlias});
                }
                    <#assign i = i + 1 />
                </#if>
            </#list>

                cursor.addRow(row);
                result = true;
            } catch (JSONException e) {
                Log.e(TAG, e.getMessage());
            }
        }

        return result;
    }

    /**
     * Extract a list of <T> from a JSONObject describing an array of <T> given the array name.
     * @param json The JSONObject describing the array of <T>
     * @param items The returned list of <T>
     * @param paramName The name of the array
     * @return The number of <T> found in the JSON
     */
    public int extractItems(JSONObject json,
            String paramName,
            List<${curr.name}> items) throws JSONException {

        return this.extractItems(json, paramName, items, 0);
    }

    /**
     * Extract a list of <T> from a JSONObject describing an array of <T> given the array name.
     * @param json The JSONObject describing the array of <T>
     * @param items The returned list of <T>
     * @param paramName The name of the array
     * @param limit Limit the number of items to parse
     * @return The number of <T> found in the JSON
     */
    public int extractItems(JSONObject json,
            String paramName,
            List<${curr.name}> items,
            int limit) throws JSONException {

        JSONArray itemArray = json.optJSONArray(paramName);

        int result = -1;

        if (itemArray != null) {
            int count = itemArray.length();

            if (limit > 0 && count > limit) {
                count = limit;
            }

            for (int i = 0; i < count; i++) {
                JSONObject jsonItem = itemArray.getJSONObject(i);
                ${curr.name} item = new ${curr.name}();
                this.extract(jsonItem, item);
                if (item!=null) {
                    synchronized (items) {
                        items.add(item);
                    }
                }
            }
        }

        if (!json.isNull("Meta")) {
            JSONObject meta = json.optJSONObject("Meta");
            result = meta.optInt("nbt",0);
        }

        return result;
    }

    /**
     * Convert a ${curr.name} to a JSONObject.
     * @param ${curr.name?uncap_first} The ${curr.name} to convert
     * @return The converted ${curr.name}
     */
    public JSONObject itemToJson(${curr.name} ${curr.name?uncap_first}) {
        <#if (InheritanceUtils.isExtended(curr))>
        JSONObject params =
                this.motherAdapter.itemToJson(${curr.name?uncap_first});
        <#else>
        JSONObject params = new JSONObject();
        </#if>
        try {
            <#list curr.fields?values as field>
                <#if (!field.internal)>
                    <#if (!field.relation??)>
                        <#if (curr.options.sync?? && field.name?lower_case=="id")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${curr.name}WebServiceClientAdapter.JSON_ID,
                    ${curr.name?uncap_first}.getServerId());
                        </#if><#elseif (curr.options.sync?? && field.name=="serverId")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${curr.name}WebServiceClientAdapter.JSON_MOBILE_ID,
                    ${curr.name?uncap_first}.getId());
                        </#if><#elseif (curr.options.sync?? && field.name=="sync_uDate")><#if !InheritanceUtils.isExtended(curr)>

            if (${curr.name?uncap_first}.get${field.name?cap_first}() != null) {
                params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                        ${curr.name?uncap_first}.get${field.name?cap_first}().toString(SYNC_UPDATE_DATE_FORMAT));
            }
                        </#if><#elseif (FieldsUtils.getJavaType(field)?lower_case == "datetime")>

            if (${curr.name?uncap_first}.get${field.name?cap_first}() != null) {
                params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                        ${curr.name?uncap_first}.get${field.name?cap_first}().toString(REST_UPDATE_DATE_FORMAT));
            }
                        <#elseif (FieldsUtils.getJavaType(field)?lower_case == "boolean")>
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    ${curr.name?uncap_first}.is${field.name?cap_first}());
                        <#elseif (field.harmony_type=="enum")>

            if (${curr.name?uncap_first}.get${field.name?cap_first}() != null) {
                            <#if enums[field.enum.targetEnum].id??>
                params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                        ${curr.name?uncap_first}.get${field.name?cap_first}().getValue());
                            <#else>
                params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                        ${curr.name?uncap_first}.get${field.name?cap_first}().name());
                            </#if>
            }
                        <#else>
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    ${curr.name?uncap_first}.get${field.name?cap_first}());
                        </#if>
                    <#else>
                        <#if (isRestEntity(field.relation.targetEntity))>
                            <#if (field.relation.type == "ManyToMany" || field.relation.type == "OneToMany")>
                                <#assign converter = "itemsIdToJson" />
                            <#else>
                                <#assign converter = "itemIdToJson" />
                            </#if>

            if (${curr.name?uncap_first}.get${field.name?cap_first}() != null) {
                ${field.relation.targetEntity?cap_first}WebServiceClientAdapter ${field.name}Adapter =
                        new ${field.relation.targetEntity?cap_first}WebServiceClientAdapter(this.context);

                params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                        ${field.name}Adapter.${converter}(${curr.name?uncap_first}.get${field.name?cap_first}()));
            }
                        </#if>
                    </#if>
                </#if>
            </#list>
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        }

        return params;
    }


    /**
     * Convert a <T> to a JSONObject.
     * @param item The <T> to convert
     * @return The converted <T>
     */
    public JSONObject itemIdToJson(${curr.name?cap_first} item) {
        JSONObject params = new JSONObject();
        try {
            <#if curr.options.sync??>
            params.put(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, item.getServerId());
            <#else>
                <#list curr_ids as id>
            params.put(${id.owner}WebServiceClientAdapter.${alias(id.name)}, item.get${id.name?cap_first}());
                </#list>
            </#if>
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        }

        return params;
    }


    /**
     * Converts a content value reprensenting a ${curr.name} to a JSONObject.
     * @param The content values
     * @return The JSONObject
     */
    public JSONObject contentValuesToJson(ContentValues values) {
        <#if (InheritanceUtils.isExtended(curr))>
        JSONObject params = this.motherAdapter.contentValuesToJson(values);
        <#else>
        JSONObject params = new JSONObject();
        </#if>

        try {
            <#list restFields as field>
                    <#if (curr.options.sync?? && field.name?lower_case=="id")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${curr.name}WebServiceClientAdapter.JSON_ID,
                    values.get(${curr.name?cap_first}Contract.COL_SERVERID));
                    </#if><#elseif (curr.options.sync?? && field.name=="serverId")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${curr.name}WebServiceClientAdapter.JSON_MOBILE_ID,
                    values.get(${curr.name?cap_first}Contract.COL_ID));
                    </#if><#elseif (curr.options.sync?? && field.name=="sync_uDate")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    new DateTime(values.get(
                            ${ContractUtils.getContractCol(field)})).toString(SYNC_UPDATE_DATE_FORMAT));
            </#if><#elseif (curr.options.sync?? && field.name == "hash")><#if !InheritanceUtils.isExtended(curr)>
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    values.get(${curr.name?cap_first}Contract.COL_HASH));
                    </#if><#else>
                        <#if FieldsUtils.getJavaType(field)?lower_case == "datetime">
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    new DateTime(values.get(
                            ${ContractUtils.getContractCol(field)})).toString(REST_UPDATE_DATE_FORMAT));
                        <#else>
                            <#if field.relation??>
            ${field.relation.targetEntity?cap_first}WebServiceClientAdapter ${field.name}Adapter =
                    new ${field.relation.targetEntity?cap_first}WebServiceClientAdapter(this.context);

            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    ${field.name}Adapter.contentValuesToJson(values));
                            <#else>
            params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)},
                    values.get(${ContractUtils.getContractCol(field)}));
                            </#if>
                        </#if>
                    </#if>
            </#list>
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        }

        return params;
    }

<#if (curr.options.sync??)>
    @Override
    public String getSyncUri() {
        return "${curr.options.sync.syncUri}";
    }
</#if>
}
