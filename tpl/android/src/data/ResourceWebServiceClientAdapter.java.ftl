<@header?interpret />
package ${data_namespace};

import ${data_namespace}.base.ResourceWebServiceClientAdapterBase;
import ${data_namespace}.base.WebServiceClientAdapterBase;
import ${entity_namespace}.base.EntityResourceBase;

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

