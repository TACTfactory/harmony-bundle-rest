<@header?interpret />
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

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

<#if (curr.options.sync??)>
    <#assign extends="SyncClientAdapterBase<Resource>" />
<#else>
    <#assign extends="WebServiceClientAdapter<Resource>" />
</#if>
/**
 *
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony.
 * You should edit WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 * @param <T> Generic Type
 */
public abstract class ResourceWebServiceClientAdapterBase
        extends ${extends} {

    /**
     * Constructor with overriden port and host.
     *
     * @param context The context
     */
    public ResourceWebServiceClientAdapterBase(Context context) {
        this(context, null);
    }

    /**
     * Constructor with overriden port.
     *
     * @param context The context
     * @param port The overriden port
     */
    public ResourceWebServiceClientAdapterBase(Context context,
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
    public ResourceWebServiceClientAdapterBase(Context context,
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
    public ResourceWebServiceClientAdapterBase(Context context,
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
    public ResourceWebServiceClientAdapterBase(Context context,
            String host, Integer port, String scheme, String prefix) {
        super(context, host, port, scheme, prefix);
    }

    @Override
    public String upload(Resource item) {
        String result = null;

        this.headers.clear();
        JSONObject json = this.itemToJson((${curr.name}) item);

        try {
            json.put(ImageUtils.IMAGE_KEY_JSON, item.getLocalPath());
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        }

        String response = this.invokeRequest(
                Verb.POST,
                String.format(
                    "%s/upload/%s",
                    this.getUri(),
                    item.getServerId(),
                    REST_FORMAT),
                    json);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            result = response;
        }

        return result;
    }

}
