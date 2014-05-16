/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.command;

import java.util.LinkedHashMap;

import net.xeoh.plugins.base.annotations.PluginImplementation;
import net.xeoh.plugins.base.annotations.meta.Author;
import net.xeoh.plugins.base.annotations.meta.Version;

import com.tactfactory.harmony.Console;
import com.tactfactory.harmony.bundles.rest.generator.RestGenerator;
import com.tactfactory.harmony.bundles.rest.parser.RestCompletor;
import com.tactfactory.harmony.bundles.rest.parser.RestParser;
import com.tactfactory.harmony.bundles.rest.platform.RestAdapter;
import com.tactfactory.harmony.bundles.rest.platform.android.RestAdapterAndroid;
import com.tactfactory.harmony.bundles.rest.platform.ios.RestAdapterIos;
import com.tactfactory.harmony.bundles.rest.platform.winphone.RestAdapterWinphone;
import com.tactfactory.harmony.command.base.CommandBundleBase;
import com.tactfactory.harmony.meta.ApplicationMetadata;
import com.tactfactory.harmony.plateforme.TargetPlatform;
import com.tactfactory.harmony.utils.ConsoleUtils;

/**
 * Command class for rest bundle.
 */
@PluginImplementation
@Author(name = "TACTfactory")
@Version(version = 00700)
public class RestCommand extends CommandBundleBase<RestAdapter> {

    //bundle name
    /** Bundle name. */
    public static final String BUNDLE = "rest";
    /** Generation subject. */
    public static final String SUBJECT = "generate";

    //actions
    /** Adapters action. */
    public static final String ACTION_ADAPTERS = "adapters";

    //commands
    /** Command: REST:GENERATE:ADAPTERS.*/
    public static final String GENERATE_ADAPTERS	= 
            BUNDLE + SEPARATOR + SUBJECT + SEPARATOR + ACTION_ADAPTERS;

    @Override
    public final void execute(final String action,
            final String[] args,
            final String option) {
        ConsoleUtils.display("> Adapters Generator");

        this.setCommandArgs(Console.parseCommandArgs(args));
        if (action.equals(GENERATE_ADAPTERS)) {
            try {
                this.generateAdapters();
            } catch (final Exception e) {
                ConsoleUtils.displayError(e);
            }
        }
    }

    /**
     * Generate java code files from parsed Entities.
     */
    protected final void generateAdapters() {

        this.generateMetas();
        if (ApplicationMetadata.INSTANCE.getEntities() != null) {
            for(RestAdapter adapter : this.getBundleAdapters()) {
                try {
                    new RestGenerator(adapter).generateAll();
                } catch (Exception e) {
                    ConsoleUtils.displayError(e);
                }
            }
        }
    }

    @Override
    public final void generateMetas() {
        this.registerParser(new RestParser());
        super.generateMetas();
        new RestCompletor().generateApplicationRestMetadata(
                ApplicationMetadata.INSTANCE);
    }

    @Override
    public final void summary() {
        LinkedHashMap<String, String> commands =
                new LinkedHashMap<String, String>();

        commands.put(GENERATE_ADAPTERS,	"Generate Engine & Adapters");

        ConsoleUtils.displaySummary(
                BUNDLE,
                commands);
    }

    @Override
    public final boolean isAvailableCommand(final String command) {
        return command.equals(GENERATE_ADAPTERS);
    }

    @Override
    public void initBundleAdapter() {
        this.adapterMapping.put(
                TargetPlatform.ANDROID,
                RestAdapterAndroid.class);
        this.adapterMapping.put(
                TargetPlatform.WINPHONE,
                RestAdapterWinphone.class);
        this.adapterMapping.put(
                TargetPlatform.IPHONE,
                RestAdapterIos.class);
    }

}
