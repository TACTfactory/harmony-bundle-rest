<@header?interpret />
<#assign curr = entities[current_entity] />

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
import ${project_namespace}.utils.ImageUtils;
import ${entity_namespace}.base.EntityResourceBase;

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

/**
 *
 * <b><i>This class will be overwrited whenever you regenerate the project with Harmony.
 * You should edit WebServiceClientAdapter class instead of this one or you will lose all your modifications.</i></b>
 * @param <T> Generic Type
 */
public abstract class ResourceWebServiceClientAdapterBase extends WebServiceClientAdapter<EntityResourceBase>{

    private WebServiceClientAdapterBase<? extends EntityResourceBase> webServiceClientAdapterBase;

    /**
     * Constructor with overriden port and host.
     *
     * @param context The context
     */
    public ResourceWebServiceClientAdapterBase(WebServiceClientAdapterBase<? extends EntityResourceBase> webServiceClientAdapterBase) {
        super(webServiceClientAdapterBase.context, webServiceClientAdapterBase.host, webServiceClientAdapterBase.port,
                webServiceClientAdapterBase.scheme, webServiceClientAdapterBase.prefix);

        this.webServiceClientAdapterBase = webServiceClientAdapterBase;
    }

    @Override
    public String getUri() {
        return this.webServiceClientAdapterBase.getUri();
    }

    public String upload(EntityResourceBase item) {
        String result = null;

        this.headers.clear();
        JSONObject json = new JSONObject();

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
