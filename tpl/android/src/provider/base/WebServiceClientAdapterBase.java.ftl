package ${data_namespace}.base;

import ${data_namespace}.*;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.message.BasicHeader;
import org.joda.time.DateTime;
import org.joda.time.format.ISODateTimeFormat;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import ${data_namespace}.RestClient.Verb;
import ${project_namespace}.R;
import ${project_namespace}.${project_name?cap_first}Application;

import android.content.Context;

import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.v4.app.FragmentActivity;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

public abstract class WebServiceClientAdapterBase<T>{
	protected static final String TAG = "WSClientAdapter";
	protected static String REST_FORMAT = ".json"; //JSon RSS xml or empty (for html)
	
	protected List<Header> headers = new ArrayList<Header>();
	protected RestClient restClient;
	protected Context context;
	protected int statusCode;
	protected int errorCode;
	protected String error;

	protected String host;
	protected int port;
	protected String scheme;
	
	protected String login = null;
	protected String password = null;

	public WebServiceClientAdapterBase(Context context){
		this(context, null, 80);
	}

	public WebServiceClientAdapterBase(Context context, int port){
		this(context, null, port);
	}

	public WebServiceClientAdapterBase(Context context, String host, int port){
		this(context, host, port, RestClient.SCHEME_HTTP);
	}
	
	public WebServiceClientAdapterBase(Context context, String host, int port, String scheme){
		this.headers.add(new BasicHeader("Content-Type","application/json"));
		this.headers.add(new BasicHeader("Accept","application/json"));

		this.context = context;
		if (host == null) {
			if (${project_name?cap_first}Application.DEBUG){
				this.host = this.context.getString(R.string.rest_url_dev);
			} else {
				this.host = this.context.getString(R.string.rest_url_prod);
			}
		} else {
			this.host = host;
		}
		
		this.port = port;
		this.scheme = scheme;
	}

	protected synchronized String invokeRequest(Verb verb, String request, JSONObject params) {
		String response = "";
		if (this.isOnline()) {
			this.restClient = new RestClient(this.host, this.port, this.scheme);
		
			if (this.login != null && !this.login.isEmpty()
					&& this.password != null && !this.password.isEmpty()) {
				this.restClient.setAuth(this.login, this.password);
			}
		
			StringBuilder error = new StringBuilder();

			try {
				synchronized (this.restClient) {
					response = this.restClient.invoke(verb, request, params, this.headers);
					this.statusCode = this.restClient.getStatusCode();
					if (isValidResponse(response)){
						this.errorCode = this.appendError(response,error);
						this.error = error.toString();
					}
				}

			} catch (Exception e) {
				this.displayOups();
			
				if (${project_name?cap_first}Application.DEBUG)
					Log.d(TAG, e.getMessage());
			}
		} else {
			Toast.makeText(this.context,
				R.string.no_network_error,
				Toast.LENGTH_SHORT).show();
		}
		return response;
	}

	/**
	 * @return the error
	 */
	public String getError() {
		return error;
	}

	protected int appendError(String response, StringBuilder error) throws JSONException {
		int result = 0;
		StringBuilder builder = new StringBuilder();
		
		JSONObject json = new JSONObject(response);
		JSONObject jsonErr = json.optJSONObject("Err");
		
		if (jsonErr != null) {
			result = jsonErr.optInt("cd");
				
			JSONArray arrayErrors = json.optJSONArray("msg");
			if (arrayErrors != null) {
				int count = arrayErrors.length();			
				
				for (int i = 0; i < count; i++) {
					error.append(arrayErrors.optString(i, null));
					if (!TextUtils.isEmpty(error.toString()))
						builder.append(error + "; ");
				}
				
				error.append(builder.toString());
			} else {
				error.append(jsonErr.optString("msg", ""));
			}
			
			if (TextUtils.isEmpty(error.toString()))
				error = null;
		}
		
		return result;
	}

	protected void displayOups() {
		this.displayOups(this.context.getString(R.string.common_network_error));
	}
	
	protected void displayOups(final String message) {
		if (context != null 
			&& !TextUtils.isEmpty(message)
			&& context instanceof FragmentActivity) {
			
			((FragmentActivity) context).runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(
							context, 
							message,//message, 
							Toast.LENGTH_SHORT)
							.show();

				}
			});
		}
	}
	
	protected boolean isValidRequest() {
		return (
				this.statusCode >= 200 && 
				this.statusCode < 300 && 
				this.errorCode == 0);
	}
	
	protected boolean isValidResponse(String response) {
		return (
				response != null && 
				!response.trim().equals("") && 
				response.startsWith("{"));
	}
	
	
	public DateTime syncTime() {
		String uri = String.format(
				"sync%s",
				REST_FORMAT);
		String response = this.invokeRequest(Verb.GET, uri , null).replace("\"", "");
		return ISODateTimeFormat.dateTimeNoMillis().parseDateTime(response);
	}
	
	
	/**
	 * Convert a <T> to a JSONObject	
	 * @param item The <T> to convert
	 * @return The converted <T>
	 */
	public abstract JSONObject itemToJson(T item);
	
	/**
	 * Convert a <T> to a JSONObject	
	 * @param item The <T> to convert
	 * @return The converted <T>
	 */
	public abstract JSONObject itemIdToJson(T item);
	
	/**
	 * Convert a list of <T> to a JSONArray	
	 * @param users The array of <T> to convert
	 * @return The array of converted <T>
	 */
	public JSONArray itemsToJson(List<T> items){
		JSONArray itemArray = new JSONArray();
		
		for (int i = 0; i < items.size(); i++) {
			JSONObject jsonItems = this.itemToJson(items.get(i));
			itemArray.put(jsonItems);
		}
		
		return itemArray;
	}
	
	
	/**
	 * Convert a list of <T> to a JSONArray	
	 * @param users The array of <T> to convert
	 * @return The array of converted <T>
	 */
	public JSONArray itemsIdToJson(List<T> items){
		JSONArray itemArray = new JSONArray();
		
		for (int i = 0; i < items.size(); i++) {
			JSONObject jsonItems = this.itemIdToJson(items.get(i));
			itemArray.put(jsonItems);
		}
		
		return itemArray;
	}
	
	/**
	 * Extract a <T> from a JSONObject describing a <T>
	 * @param json The JSONObject describing the <T>
	 * @param item The returned <T>
	 * @return true if a <T> was found. false if not
	 */
	public abstract boolean extract(JSONObject json, T item);
	
		
	/**
	 * Extract a list of <T> from a JSONObject describing an array of <T> given the array name
	 * @param json The JSONObject describing the array of <T>
	 * @param items The returned list of <T>
	 * @param paramName The name of the array
	 * @return The number of <T> found in the JSON
	 */
	public abstract int extractItems(JSONObject json, String paramName, List<T> items) throws JSONException;
	
	/**
	 * Delete a <T>. 
	 * @param item : The <T> to delete (only the id is necessary)
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public abstract int delete(T item);
	
	/**
	 * Update a <T>.
	 * @param item : The <T> to update
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public abstract int update(T item);
	
	/**
	 * Retrieve all the <T> in the given list.
	 * @param items : The list in which the <T> will be returned
	 * @return The number of <T> returned
	 */
	public abstract int getAll(List<T> items);

	/**
	 * Retrieve one <T>.
	 * @param item : The <T> to retrieve (set the ID)
	 * @return -1 if an error has occurred. 0 if not.
	 */ 
	public abstract int get(T item);
	
	
	/**
	 * Insert the User. Uses the route : user-uri
	 * @param user : The User to insert
	 * @return -1 if an error has occurred. 0 if not.
	 */
	public int insert(T item){
		int result = -1;
		String response = this.invokeRequest(
					Verb.POST,
					String.format(
						"%s%s",
						this.getUri(),
						REST_FORMAT),
					itemToJson(item));
		if (this.isValidResponse(response) && this.isValidRequest()) {
			result = 0;
		}

		return result;
	}
	
	/**
	 * 
	 * 
	 * 
	 */
	public abstract String getUri();

	/**
	 * Checks network connection.
	 * @return true if available
	 */
	public boolean isOnline() {
		boolean result = false;
		ConnectivityManager cm = (ConnectivityManager) 
				this.context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnectedOrConnecting()) {
		    result = true;
		}
		return result;
	}
	
}
