<@header?interpret />
<#assign curr = entities[current_entity] />

package ${data_namespace}.base;

import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.database.MatrixCursor;
import android.util.Log;

import ${data_namespace}.RestClient.Verb;
import ${data_namespace}.WebServiceClientAdapter;
import ${entity_namespace}.base.EntityResourceBase;
import ${project_namespace}.harmony.util.ImageUtils;

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
                    item.get<#if curr.sync??>ServerId<#else>ResourceId</#if>(),
                    REST_FORMAT),
                    json);

        if (this.isValidResponse(response) && this.isValidRequest()) {
            result = response;
        }

        return result;
    }

        @Override
    public JSONObject itemToJson(EntityResourceBase item) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public JSONObject contentValuesToJson(ContentValues values) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public JSONObject itemIdToJson(EntityResourceBase item) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public boolean extract(JSONObject json, EntityResourceBase item) {
        // TODO Auto-generated method stub
        return false;
    }

    @Override
    public int extractItems(JSONObject json, String paramName,
            List<EntityResourceBase> items) throws JSONException {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public int extractItems(JSONObject json, String paramName,
            List<EntityResourceBase> items, int limit) throws JSONException {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public int delete(EntityResourceBase item) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public int update(EntityResourceBase item) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public int getAll(List<EntityResourceBase> items) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public int get(EntityResourceBase item) {
        // TODO Auto-generated method stub
        return 0;
    }

    @Override
    public boolean extractCursor(JSONObject json, MatrixCursor cursor) {
        // TODO Auto-generated method stub
        return false;
    }

}
