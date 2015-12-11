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
import com.tactfactory.harmony.generator.BaseGenerator;
import com.tactfactory.harmony.generator.ConfigGenerator;
import com.tactfactory.harmony.generator.TagConstant;
import com.tactfactory.harmony.generator.TranslationGenerator;
import com.tactfactory.harmony.meta.ConfigMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata.Group;
import com.tactfactory.harmony.updater.IUpdater;
import com.tactfactory.harmony.utils.ConsoleUtils;

/**
 * Generator for bundle Rest.
 */
public class RestGenerator extends BaseGenerator<RestAdapter> {

    /**
     * Constructor.
     * @param adapter The used adapter.
     * @throws Exception
     */
    public RestGenerator(final RestAdapter adapter) throws Exception {
        super(adapter);
        this.setDatamodel(this.getAppMetas().toMap(this.getAdapter()));
    }

    /**
     * Generates everything.
     */
    public final void generateAll() {
        List<IUpdater> updaters = null;

        Iterable<EntityMetadata> entities =
                this.getAppMetas().getEntities().values();

        for (final EntityMetadata entity : entities) {
//            if (!entity.getFields().isEmpty()
//                    && entity.getOptions().containsKey("sync")) {
                this.getDatamodel().put(
                        TagConstant.CURRENT_ENTITY,
                        entity.getName());

                updaters = this.getAdapter().getEntityResourceUpdaters(entity);
                this.processUpdater(updaters);
//            }
        }

        this.generateWSAdapter();

        try {
            new TestWSGenerator(this.getAdapter()).generateAll();

        } catch (final Exception e) {
            ConsoleUtils.displayError(e);
        }
    }

    /**
     * Generate WebService Adapter.
     */
    protected final void generateWSAdapter() {
        List<IUpdater> updaters = this.getAdapter().getRestUpdaters();
        this.processUpdater(updaters);

        Iterable<EntityMetadata> entities =
                this.getAppMetas().getEntities().values();

        for (final EntityMetadata entity : entities) {
            if (entity.getOptions().get("rest") != null
                    && !entity.getFields().isEmpty()) {
                this.getDatamodel().put(
                        TagConstant.CURRENT_ENTITY, entity.getName());

                updaters = this.getAdapter().getRestEntityUpdaters(entity);
                this.processUpdater(updaters);
            }
        }

        TranslationMetadata.addDefaultTranslation(
                "common_network_error",
                "Connection error",
                Group.COMMON);

        TranslationMetadata.addDefaultTranslation(
                "no_network_error",
                "No internet connection available",
                Group.COMMON);

        ConfigMetadata.addConfiguration(
                "rest_url_prod",
                "http://127.0.0.1:80/api/");

        ConfigMetadata.addConfiguration(
                "rest_url_dev",
                "http://127.0.0.1:80/api_dev/");

        ConfigMetadata.addConfiguration(
                "rest_check_ssl",
                "true");

        ConfigMetadata.addConfiguration(
                "rest_ssl",
                "ca.cert");

        try {
            new TranslationGenerator(this.getAdapter()).generateStringsXml();
            new ConfigGenerator(this.getAdapter()).generateConfigFile();
        } catch (final Exception e) {
            ConsoleUtils.displayError(e);
        }
    }
}
