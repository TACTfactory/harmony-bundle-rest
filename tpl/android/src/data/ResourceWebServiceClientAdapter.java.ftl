<@header?interpret />
package ${data_namespace};

import android.content.Context;

import ${data_namespace}.base.ResourceWebServiceClientAdapterBase;

/**
 * Class for all your ResourceWebServiceClient adapters.
 * You can add your own/customize your methods here.
 */
public class ResourceWebServiceClientAdapter
        extends ResourceWebServiceClientAdapterBase {

    public ResourceWebServiceClientAdapter(Context context, String host,
            Integer port, String scheme, String prefix) {
        super(context, host, port, scheme, prefix);
    }
}

