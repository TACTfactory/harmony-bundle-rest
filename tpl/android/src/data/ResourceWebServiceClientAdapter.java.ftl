<@header?interpret />
package ${data_namespace};

import ${data_namespace}.base.ResourceWebServiceClientAdapterBase;
import ${data_namespace}.base.WebServiceClientAdapterBase;
import ${entity_namespace}.base.EntityResourceBase;

/**
 * Class for all your ResourceWebServiceClient adapters.
 * You can add your own/customize your methods here.
 */
public class ResourceWebServiceClientAdapter
        extends ResourceWebServiceClientAdapterBase {

    public ResourceWebServiceClientAdapter(
            WebServiceClientAdapterBase<? extends EntityResourceBase> webServiceClientAdapterBase) {
        super(webServiceClientAdapterBase);
    }

    public ResourceWebServiceClientAdapter(Context context, String host,
            Integer port, String scheme, String prefix) {
        super(context, host, port, scheme, prefix);
    }
}

