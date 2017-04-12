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
import com.tactfactory.harmony.bundles.rest.meta.RestMetadata;
import com.tactfactory.harmony.meta.ApplicationMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.test.factory.ManagementFactory;

public class RestManagementFactory extends ManagementFactory {

    /**
     * Generate the test metadata.
     *
     * @return The test metadata
     */
    @Override
    public ApplicationMetadata getTestMetadata() {
        ApplicationMetadata applicationMetadata = super.getTestMetadata();

        for (EntityMetadata entity : applicationMetadata.getEntities().values()) {
            if (!entity.isInternal()) {
                // Add import
                entity.getImports().add(Rest.class.getSimpleName());

                // Add metadata
                RestMetadata restMetadata = new RestMetadata();
                restMetadata.setUri(entity.getName());
                entity.getOptions().put(RestMetadata.NAME, restMetadata);
            }
        }

        return applicationMetadata;
    }
}
