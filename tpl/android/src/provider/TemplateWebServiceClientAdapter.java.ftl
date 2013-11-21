<#assign curr = entities[current_entity] />
package ${curr.data_namespace};

import ${data_namespace}.base.${curr.name}WebServiceClientAdapterBase;
import android.content.Context;

public class ${curr.name}WebServiceClientAdapter
		extends ${curr.name}WebServiceClientAdapterBase {
	
	public ${curr.name}WebServiceClientAdapter(Context context) {
		super(context);
	}

	public ${curr.name}WebServiceClientAdapter(Context context,
			Integer port) {
		super(context, port);
	}

	public ${curr.name}WebServiceClientAdapter(Context context,
			String host, Integer port) {
		super(context, host, port);
	}
	
	public ${curr.name}WebServiceClientAdapter(Context context,
			String host, Integer port, String scheme) {
		super(context, host, port, scheme);
	}
	
	public ${curr.name}WebServiceClientAdapter(Context context,
			String host, Integer port, String scheme, String prefix) {
		super(context, host, port, scheme, prefix);
	}
}
