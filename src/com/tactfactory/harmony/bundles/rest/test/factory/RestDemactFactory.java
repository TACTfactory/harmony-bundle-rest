package com.tactfactory.harmony.bundles.rest.test.factory;

import com.tactfactory.harmony.bundles.rest.annotation.Rest;
import com.tactfactory.harmony.bundles.rest.annotation.Rest.Security;
import com.tactfactory.harmony.bundles.rest.meta.RestMetadata;
import com.tactfactory.harmony.meta.ApplicationMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.test.factory.DemactFactory;

public class RestDemactFactory extends DemactFactory {
	
	/**
	 * Generate the test metadata.
	 * 
	 * @return The test metadata
	 */
	public static ApplicationMetadata generateTestMetadata() {
		ApplicationMetadata applicationMetadata =
				DemactFactory.generateTestMetadata();
		
		EntityMetadata user = applicationMetadata.getEntities().get("User");
		EntityMetadata client = applicationMetadata.getEntities().get("Client");
		EntityMetadata comment =
				applicationMetadata.getEntities().get("Comment");
		EntityMetadata post = applicationMetadata.getEntities().get("Post");
		
		// Set import
		user.getImports().add(Rest.class.getSimpleName());
		user.getImports().add(Rest.Security.class.getSimpleName());
		client.getImports().add(Rest.class.getSimpleName());
		comment.getImports().add(Rest.class.getSimpleName());
		post.getImports().add(Rest.class.getSimpleName());
		
		// Set rest metadata
		RestMetadata restMetadata = new RestMetadata();
		restMetadata.setSecurity(Security.SESSION);
		restMetadata.setUri("user-uri");
		user.getOptions().put(RestMetadata.NAME, restMetadata);
		
		restMetadata = new RestMetadata();
		restMetadata.setUri("Client");
		client.getOptions().put(RestMetadata.NAME, restMetadata);
		
		restMetadata = new RestMetadata();
		restMetadata.setUri("Comment");
		comment.getOptions().put(RestMetadata.NAME, restMetadata);
		
		restMetadata = new RestMetadata();
		restMetadata.setUri("Post");
		post.getOptions().put(RestMetadata.NAME, restMetadata);
				
		return applicationMetadata;
	}
}
