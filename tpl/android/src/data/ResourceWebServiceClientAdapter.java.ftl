<@header?interpret />
package ${data_namespace};

import ${data_namespace}.base.ResourceWebServiceClientAdapterBase;

import android.content.Context;

/**
 * Class for all your ResourceWebServiceClient adapters.
 * You can add your own/customize your methods here.
 */
public abstract class ResourceWebServiceClientAdapter<T>
        extends ResourceWebServiceClientAdapterBase {

    public ResourceWebServiceClientAdapter(
            WebServiceClientAdapterBase<EntityResourceBase> webServiceClientAdapterBase) {
        super(webServiceClientAdapterBase);
    }
}

