/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.generator;

import java.util.List;

import com.tactfactory.harmony.bundles.rest.platform.RestAdapter;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.template.BaseGenerator;
import com.tactfactory.harmony.template.TagConstant;
import com.tactfactory.harmony.updater.IUpdater;
import com.tactfactory.harmony.utils.ConsoleUtils;

/**
 * WebService tests generator.
 *
 */
public class TestWSGenerator extends BaseGenerator<RestAdapter> {

    /**
     * Constructor. 
     * @param adapter The {@link RestAdapter} to use.
     * @throws Exception 
     */
    public TestWSGenerator(final RestAdapter adapter) throws Exception {
        super(adapter);
        this.setDatamodel(this.getAppMetas().toMap(this.getAdapter()));
    }

    /**
     * Generate all tests for Rest.
     */
    public final void generateAll() {
        ConsoleUtils.display(">> Generate Rest test...");

        List<IUpdater> updaters = this.getAdapter().getRestUpdatersTest();
        this.processUpdater(updaters);

        Iterable<EntityMetadata> entities =
                this.getAppMetas().getEntities().values();

        for (final EntityMetadata entity : entities) {
            if (entity.getOptions().containsKey("rest") 
                    && !entity.isInternal() 
                    && !entity.getFields().isEmpty()) {

                ConsoleUtils.display(">>> Generate Rest test for " 
                        +  entity.getName());

                this.getDatamodel().put(
                        TagConstant.CURRENT_ENTITY, entity.getName());

                updaters = this.getAdapter()
                        .getRestEntityUpdatersTest(entity);
                this.processUpdater(updaters);
            }
        }
    }
}
