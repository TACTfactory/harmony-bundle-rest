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

    /**
     * Default constructor.
     * to define the url components.
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
    public ResourceWebServiceClientAdapterBase(Context context, Integer port) {
        this(context, null, port);
    }

    /**
     * Constructor with overriden port and host.
     *
     * @param context The context
     * @param host The overriden host
     * @param port The overriden port
     */
    public ResourceWebServiceClientAdapterBase(Context context, String host, Integer port) {
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

}

