/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
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
    @Override
    public ApplicationMetadata getTestMetadata() {
        ApplicationMetadata applicationMetadata = super.getTestMetadata();

        EntityMetadata user = applicationMetadata.getEntities().get("User");
        EntityMetadata client = applicationMetadata.getEntities().get("Client");
        EntityMetadata comment =
                applicationMetadata.getEntities().get("Comment");
        EntityMetadata post = applicationMetadata.getEntities().get("Post");
        EntityMetadata group = applicationMetadata.getEntities().get("Group");
        EntityMetadata groupToComment = applicationMetadata.getEntities().get("GroupToComment");

        // Set import
        user.getImports().add(Rest.class.getSimpleName());
        user.getImports().add(Rest.Security.class.getSimpleName());
        client.getImports().add(Rest.class.getSimpleName());
        comment.getImports().add(Rest.class.getSimpleName());
        post.getImports().add(Rest.class.getSimpleName());
        group.getImports().add(Rest.class.getSimpleName());
        groupToComment.getImports().add(Rest.class.getSimpleName());

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

        restMetadata = new RestMetadata();
        restMetadata.setUri("Group");
        group.getOptions().put(RestMetadata.NAME, restMetadata);

        restMetadata = new RestMetadata();
        restMetadata.setUri("GroupToComment");
        groupToComment.getOptions().put(RestMetadata.NAME, restMetadata);

        return applicationMetadata;
    }
}
