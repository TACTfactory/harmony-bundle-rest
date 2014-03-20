<#include utilityPath + "all_imports.ftl" />
<#assign curr = entities[current_entity] />
<#function alias name>
	<#return "JSON_"+name?upper_case />
</#function>
<#function typeToJsonType field>
	<#if (!field.relation??)>
		<#if (field.type=="int" || field.type=="integer")>
			<#return "Int" />
		<#elseif (field.type=="float")>
			<#return "Float" />
		<#elseif (field.type=="double")>
			<#return "Double" />
		<#elseif (field.type=="long")>
			<#return "Long" />
		<#elseif (field.type=="boolean")>
			<#return "Boolean" />
		<#elseif (field.harmony_type=="enum")>
			<#assign enumType = enums[field.type] />
			<#if enumType.id??>
				<#assign idEnum = enumType.fields[enumType.id] />
				<#if (idEnum.type?lower_case == "int" || idEnum.type?lower_case == "integer") >
					<#return "Int" />
				<#else>
					<#return "String" />
				</#if>
			<#else>
				<#return "String" />
			</#if>
		<#else>
			<#return "String" />
		</#if>
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
		<#if (!field.relation??)>
			<#if (field.type=="date"||field.type=="datetime"||field.type=="time")>
		DateTimeFormatter ${field.name?uncap_first}Formatter = ${getFormatter(field.type)};
		${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first}Formatter.parseDateTime(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().toString())));	
			<#elseif (field.type=="boolean")>
		${curr.name?uncap_first}.set${field.name?cap_first}(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.is${field.name?cap_first}()));	
			<#else>
		${curr.name?uncap_first}.set${field.name?cap_first}(json.opt${typeToJsonType(field)}(${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}()));	
			</#if>
		<#else>
			<#if (isRestEntity(field.relation.targetEntity))>
				<#if (field.relation.type=="OneToMany" || field.relation.type=="ManyToMany")>
		ArrayList<${field.relation.targetEntity}> ${field.name?uncap_first} = new ArrayList<${field.relation.targetEntity}>();
		try {
		${field.relation.targetEntity}WebServiceClientAdapter.extract${field.relation.targetEntity}s(json.opt${typeToJsonType(field)}(${alias(field.name)}), ${field.name?uncap_first});
		${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
		} catch (JSONException e){
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
<#function getFormatter datetype>
	<#assign ret="ISODateTimeFormat." />
	<#if (datetype?lower_case=="datetime")>
		<#assign ret=ret+"dateTime()" />
	<#elseif (datetype?lower_case=="time")>
		<#assign ret=ret+"dateTime()" />
	<#elseif (datetype?lower_case=="date")>
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
	<#if !importDate && (field.type?lower_case == "datetime")>
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
<#if curr.inheritance?? && curr.inheritance.superclass??>import ${project_namespace}.provider.contract.${curr.inheritance.superclass.name?cap_first}Contract;</#if>
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
	protected static final String TAG = "${curr.name}WSClientAdapter";

	protected static String ${alias(curr.name)} = "${curr.name}";
	<#list curr.fields?values as field>
		<#if (!field.internal)>
			<#if (!field.relation?? || isRestEntity(field.relation.targetEntity))>
	protected static String ${alias(field.name)} = "${field.name?uncap_first}";
			</#if>
		</#if>
	</#list>
	<#if (curr.options.sync??)>
	protected static String JSON_MOBILE_ID = "mobile_id";

	/** Sync Date Format pattern. */
	public static final String SYNC_UPDATE_DATE_FORMAT = "${curr.options.sync.updateDateFormatJava}";
	</#if>

	/** Rest Date Format pattern. */
	public static final String REST_UPDATE_DATE_FORMAT = "${curr.options.rest.dateFormat}";

	public static String[] REST_COLS = new String[]{
			<#list curr.fields?values as field>
				<#if (!field.internal)>
					<#if (!field.relation??)>
			${curr.name?cap_first}Contract.${curr.name}.COL_${field.name?upper_case}<#if field_has_next>,</#if>
					<#else>
						<#if (isRestEntity(field.relation.targetEntity))>
							<#if (field.relation.type=="OneToOne" || field.relation.type=="ManyToOne")>
			${curr.name?cap_first}Contract.${curr.name}.COL_${field.name?upper_case}<#if field_has_next>,</#if>
							</#if>
						</#if>
					</#if>
				</#if>
			</#list>
		};


	<#if (joinedInheritance || (singleTabInheritance && curr.inheritance.superclass??))>
	protected ${curr.inheritance.superclass.name}WebServiceClientAdapter motherAdapter;
	</#if>

	public ${curr.name}WebServiceClientAdapterBase(Context context) {
		this(context, null);
	}

	public ${curr.name}WebServiceClientAdapterBase(Context context,
		Integer port) {
		this(context, null, port);
	}

	public ${curr.name}WebServiceClientAdapterBase(Context context,
			String host, Integer port) {
		this(context, host, port, null);
	}
	
	public ${curr.name}WebServiceClientAdapterBase(Context context,
			String host, Integer port, String scheme) {
		this(context, host, port, scheme, null);
	}
	
	public ${curr.name}WebServiceClientAdapterBase(Context context,
			String host, Integer port, String scheme, String prefix) {
		super(context, host, port, scheme, prefix);
		<#if (joinedInheritance || (singleTabInheritance && curr.inheritance.superclass??))>
		this.motherAdapter =
			new ${curr.inheritance.superclass.name}WebServiceClientAdapter(
				context, host, port, scheme, prefix);
		</#if>
	}
	
	/**
	 * Retrieve all the ${curr.name}s in the given list. Uses the route : ${curr.options.rest.uri}
	 * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
	 * @return The number of ${curr.name}s returned
	 */
	public int getAll(List<${curr.name}> ${curr.name?uncap_first}s){
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
	 * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%
	 * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the ID)
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public int get(${curr.name} ${curr.name?uncap_first}){
		int result = -1;
		String response = this.invokeRequest(
					Verb.GET,
					String.format(
						this.getUri() + "/%s%s",
						${curr.name?uncap_first}.getId(), 
						REST_FORMAT),
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
	 * Retrieve one ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%
	 * @param ${curr.name?uncap_first} : The ${curr.name} to retrieve (set the ID)
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public Cursor query(String id){
		String[] cursorColumns = new String[${restFields?size}];
		<#assign i = 0 />
		<#list restFields as field>
		cursorColumns[${i}] = ${field.owner?cap_first}Contract.${field.owner}.${NamingUtils.alias(field.name)};
			<#assign i = i + 1 />
		</#list>
		MatrixCursor result = new MatrixCursor(cursorColumns);
		String response = this.invokeRequest(
					Verb.GET,
					String.format(
						this.getUri() + "/%s%s",
						id, 
						REST_FORMAT),
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

	public String getUri(){
		return "${curr.options.rest.uri}";
	}

	/**
	 * Update a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%
	 * @param ${curr.name?uncap_first} : The ${curr.name} to update
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public int update(${curr.name} ${curr.name?uncap_first}){
		int result = -1;
		String response = this.invokeRequest(
					Verb.PUT,
					String.format(
						this.getUri() + "/%s%s",
						${curr.name?uncap_first}.getId(),
						REST_FORMAT),
					itemToJson(${curr.name?uncap_first}));
		if (this.isValidResponse(response) && this.isValidRequest()) {
			result = 0;
		}

		return result;
	}

	/**
	 * Delete a ${curr.name}. Uses the route : ${curr.options.rest.uri}/%id%
	 * @param ${curr.name?uncap_first} : The ${curr.name} to delete (only the id is necessary)
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public int delete(${curr.name} ${curr.name?uncap_first}){
		int result = -1;
		String response = this.invokeRequest(
					Verb.DELETE,
					String.format(
						this.getUri() + "/%s%s",
						${curr.name?uncap_first}.getId(), 
						REST_FORMAT),
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
	 * Get the ${curr.name}s associated with a ${relation.relation.targetEntity}. Uses the route : ${entities[relation.relation.targetEntity].options.rest.uri?lower_case}/%${relation.relation.targetEntity}_id%/${curr.options.rest.uri?lower_case}
	 * @param ${curr.name?uncap_first}s : The list in which the ${curr.name}s will be returned
	 * @param ${relation.relation.targetEntity?lower_case} : The associated ${relation.relation.targetEntity?lower_case}
	 * @return The number of ${curr.name}s returned
	 */
	public int getBy${relation.name?cap_first}(List<${curr.name}> ${curr.name?uncap_first}s, ${relation.relation.targetEntity} ${relation.relation.targetEntity?lower_case}){
		int result = -1;
		String response = this.invokeRequest(
					Verb.GET,
					String.format(
						this.getUri() + "/${relation.name?lower_case}/%s%s",
						${relation.relation.targetEntity?lower_case}.getId(), 
						REST_FORMAT),
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
	 * Get the ${curr.name} associated with a ${relation.relation.targetEntity}. Uses the route : ${entities[relation.relation.targetEntity].options.rest.uri?lower_case}/%${relation.relation.targetEntity}_id%/${curr.options.rest.uri?lower_case}
	 * @param ${curr.name?uncap_first} : The ${curr.name} that will be returned
	 * @param ${relation.relation.targetEntity?lower_case} : The associated ${relation.relation.targetEntity?lower_case}
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public int getBy${relation.relation.targetEntity}(${curr.name} ${curr.name?uncap_first}, ${relation.relation.targetEntity} ${relation.relation.targetEntity?uncap_first}){
		int result = -1;
		String response = this.invokeRequest(
					Verb.GET,
					String.format(
						this.getUri() + "/${relation.name?lower_case}/%s%s",
						${relation.relation.targetEntity?uncap_first}.getId(), 
						REST_FORMAT),
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
		boolean result = false;
		int id = json.optInt(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, 0);

		result = (id != 0);

		return result;
	}

	/**
	 * Extract a ${curr.name} from a JSONObject describing a ${curr.name}
	 * @param json The JSONObject describing the ${curr.name}
	 * @param ${curr.name?uncap_first} The returned ${curr.name}
	 * @return true if a ${curr.name} was found. false if not
	 */
	public boolean extract(JSONObject json, ${curr.name} ${curr.name?uncap_first}){		
		boolean result = this.isValidJSON(json);		
		<#if (joinedInheritance || (singleTabInheritance && curr.inheritance.superclass??))>
		this.motherAdapter.extract(json, ${curr.name?uncap_first});
		</#if>
		if (result) {
			try {
			<#list curr.fields?values as field>
				<#if (!field.internal)>
					<#if (!field.relation??)>

						<#if (curr.options.sync?? && field.name?lower_case=="id")>
				if (json.has(${field.owner}WebServiceClientAdapter.JSON_MOBILE_ID)) {
					${curr.name?uncap_first}.setId(json.getInt(JSON_MOBILE_ID));			
						<#elseif (curr.options.sync?? && field.name=="serverId")>
				if (json.has(${field.owner}WebServiceClientAdapter.JSON_ID)) {
					int server_id = json.optInt(${curr.name}WebServiceClientAdapter.JSON_ID);
				
					if (server_id != 0) {
						${curr.name?uncap_first}.setServerId(server_id);	
					}			
						<#else>
				if (json.has(${field.owner}WebServiceClientAdapter.${alias(field.name)})) {
							<#if (field.type?lower_case == "datetime")>
					DateTimeFormatter ${field.name?uncap_first}Formatter = <#if (curr.options.sync?? && field.name=="sync_uDate")>DateTimeFormat.forPattern(SYNC_UPDATE_DATE_FORMAT)<#else>DateTimeFormat.forPattern(REST_UPDATE_DATE_FORMAT)</#if>;
					${curr.name?uncap_first}.set${field.name?cap_first}(
							${field.name?uncap_first}Formatter.withOffsetParsed().parseDateTime(
									json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)})));
							<#elseif (field.type=="boolean")>
					${curr.name?uncap_first}.set${field.name?cap_first}(json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));	
							<#elseif (field.harmony_type == "enum")>
								<#if enums[field.type].id??>
					${curr.name?uncap_first}.set${field.name?cap_first}(${field.type}.fromValue(json.get${typeToJsonType(field)}(
								${field.owner}WebServiceClientAdapter.${alias(field.name)})));	
								<#else>
					${curr.name?uncap_first}.set${field.name?cap_first}(${field.type}.valueOf(json.get${typeToJsonType(field)}(
									${field.owner}WebServiceClientAdapter.${alias(field.name)})));	
								</#if>
							<#else>
					${curr.name?uncap_first}.set${field.name?cap_first}(json.get${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}));	
							</#if>
						</#if>
				}
					<#else>
						<#if (isRestEntity(field.relation.targetEntity))>
				if (json.has(${field.owner}WebServiceClientAdapter.${alias(field.name)})) {
							<#if (field.relation.type=="OneToMany" || field.relation.type=="ManyToMany")>
					ArrayList<${field.relation.targetEntity}> ${field.name?uncap_first} = new ArrayList<${field.relation.targetEntity}>();
					${field.relation.targetEntity}WebServiceClientAdapter ${field.name}Adapter = new ${field.relation.targetEntity}WebServiceClientAdapter(this.context);
					try {
						//.opt${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)})
						${field.name}Adapter.extractItems(json, ${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${field.name?uncap_first});
						${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
					} catch (JSONException e){
						Log.e(TAG, e.getMessage());
					}
							<#else>
								<#if (curr.options.sync??)>
					${field.relation.targetEntity}SQLiteAdapter ${field.name}Adapter = new ${field.relation.targetEntity}SQLiteAdapter(this.context);
					${field.name}Adapter.open();
					${curr.name?uncap_first}.set${field.name?cap_first}(${field.name}Adapter.getByServerID(
							json.optJSONObject(JSON_${field.name?upper_case}).optInt(JSON_ID)));
					${field.name}Adapter.close();
								<#else>
					${field.relation.targetEntity}WebServiceClientAdapter ${field.name}Adapter = new ${field.relation.targetEntity}WebServiceClientAdapter(this.context);
					${field.relation.targetEntity} ${field.name?uncap_first} = new ${field.relation.targetEntity}();
					if (${field.name}Adapter.extract(json.opt${typeToJsonType(field)}(${field.owner}WebServiceClientAdapter.${alias(field.name)}), ${field.name?uncap_first})) {
						${curr.name?uncap_first}.set${field.name?cap_first}(${field.name?uncap_first});
					}
								</#if>
							</#if>
				}
						</#if>
					</#if>
				</#if>
			</#list>
			} catch (JSONException e) {
				Log.e(TAG, e.getMessage());
			}
		} 
		return result;
	}

	@Override
	public boolean extractCursor(JSONObject json, MatrixCursor cursor){
		boolean result = false;
		String id = json.optString(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, null);
		if (id != null) {
			try {
				String[] row = new String[${restFields?size}];
			<#assign i = 0 />
			<#list restFields as field>
				if (json.has(${field.owner}WebServiceClientAdapter.${alias(field.name)})) {
					row[${i}] = json.getString(${field.owner}WebServiceClientAdapter.${alias(field.name)});	
				}
				<#assign i = i + 1 />
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
	 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name
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
	 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name
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
				if (item!=null){
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
	 * Convert a ${curr.name} to a JSONObject	
	 * @param ${curr.name?uncap_first} The ${curr.name} to convert
	 * @return The converted ${curr.name}
	 */
	public JSONObject itemToJson(${curr.name} ${curr.name?uncap_first}){
		<#if (joinedInheritance || (singleTabInheritance && curr.inheritance.superclass??))>
		JSONObject params = this.motherAdapter.itemToJson(${curr.name?uncap_first});
		<#else>
		JSONObject params = new JSONObject();
		</#if>
		try {
			<#list curr.fields?values as field>
				<#if (!field.internal)>
					<#if (!field.relation??)>
						<#if (curr.options.sync?? && field.name?lower_case=="id")>
			params.put(${curr.name}WebServiceClientAdapter.JSON_ID, ${curr.name?uncap_first}.getServerId());
						<#elseif (curr.options.sync?? && field.name=="serverId")>
			params.put(${curr.name}WebServiceClientAdapter.JSON_MOBILE_ID, ${curr.name?uncap_first}.getId());
						<#elseif (curr.options.sync?? && field.name=="sync_uDate")>
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().toString(SYNC_UPDATE_DATE_FORMAT));
						<#elseif (field.type=="date" || field.type=="time" || field.type=="datetime")>
			if (${curr.name?uncap_first}.get${field.name?cap_first}()!=null){
				params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().toString(REST_UPDATE_DATE_FORMAT));
			}
						<#elseif (field.type=="boolean")>
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.is${field.name?cap_first}());
						<#elseif (field.harmony_type=="enum")>
			if (${curr.name?uncap_first}.get${field.name?cap_first}() != null) {
							<#if enums[field.type].id??>
				params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().getValue());
							<#else>
				params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}().name());
							</#if>
			}
						<#else>
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${curr.name?uncap_first}.get${field.name?cap_first}());
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
				params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, ${field.name}Adapter
					.${converter}(${curr.name?uncap_first}.get${field.name?cap_first}()));
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
	 * Convert a <T> to a JSONObject	
	 * @param item The <T> to convert
	 * @return The converted <T>
	 */
	public JSONObject itemIdToJson(${curr.name?cap_first} item){
		JSONObject params = new JSONObject();
		try {
			<#if curr.options.sync??>
			params.put(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, item.getServerId());
			<#else>
			params.put(${curr.ids[0].owner}WebServiceClientAdapter.${alias(curr.ids[0].name)}, item.getId());
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
		<#if (joinedInheritance || (singleTabInheritance && curr.inheritance.superclass??))>
		JSONObject params = this.motherAdapter.contentValuesToJson(values);
		<#else>
		JSONObject params = new JSONObject();
		</#if>
		try {
			<#list curr.fields?values as field>
				<#if (!field.internal)>
					<#if (!field.relation?? || ((field.relation.type == "ManyToOne" || field.relation.type == "OneToOne") && entities[field.relation.targetEntity].options.rest??))>
						<#if (curr.options.sync?? && field.name?lower_case=="id")>
			params.put(${curr.name}WebServiceClientAdapter.JSON_ID, values.get(${curr.name?cap_first}Contract.${curr.name}.COL_${field.name?upper_case}.COL_SERVERID));
						<#elseif (curr.options.sync?? && field.name=="serverId")>
			params.put(${curr.name}WebServiceClientAdapter.JSON_MOBILE_ID, values.get(${curr.name?cap_first}Contract.${curr.name}.COL_${field.name?upper_case}.COL_ID));
						<#elseif (curr.options.sync?? && field.name=="sync_uDate")>		
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, new DateTime(values.get(${curr.name?cap_first}Contract.${curr.name}.${NamingUtils.alias(field.name)})).toString(SYNC_UPDATE_DATE_FORMAT));
						<#else>
							<#if field.type?lower_case == "datetime">
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, new DateTime(values.get(${curr.name?cap_first}Contract.${curr.name}.${NamingUtils.alias(field.name)})).toString(REST_UPDATE_DATE_FORMAT));
							<#else>
			params.put(${field.owner}WebServiceClientAdapter.${alias(field.name)}, values.get(${curr.name?cap_first}Contract.${curr.name}.${NamingUtils.alias(field.name)}));
							</#if>
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
