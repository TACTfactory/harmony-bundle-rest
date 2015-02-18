/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.platform.ios;

import java.util.ArrayList;
import java.util.List;

import com.tactfactory.harmony.bundles.rest.platform.RestAdapter;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.platform.ios.IosAdapter;
import com.tactfactory.harmony.updater.IUpdater;
import com.tactfactory.harmony.updater.impl.SourceFile;

/**
 * RestAdapter Adapter for IOS.
 * @author Erwan Le Huitouze (erwan.lehuitouze@tactfactory.com)
 *
 */
public class RestAdapterIos extends IosAdapter implements RestAdapter {

    @Override
    public List<IUpdater> getRestUpdaters() {
        List<IUpdater> result = new ArrayList<IUpdater>();

        String templatePath = this.getTemplateSourceProviderPath();
        String filePath = this.getSourcePath()
                + "/Data/WebService/";
 
        result.add(new SourceFile(
                templatePath + "base/WebServiceClientAdapterBase.h",
                filePath + "base/WebServiceClientAdapterBase.h",
                true));

        result.add(new SourceFile(
                templatePath + "base/WebServiceClientAdapterBase.m",
                filePath + "base/WebServiceClientAdapterBase.m",
                true));

        // Make Abstract Adapter Base general for all entities
        result.add(new SourceFile(
                templatePath + "WebServiceClientAdapter.h", 
                filePath + "WebServiceClientAdapter.h",
                false));
        
        result.add(new SourceFile(
                templatePath + "WebServiceClientAdapter.m", 
                filePath + "WebServiceClientAdapter.m",
                false));

        // Make RestClient
        result.add(new SourceFile(
                templatePath + "RPCClient.h", 
                filePath + "RPCClient.h",
                false));

        result.add(new SourceFile(
                templatePath + "RPCClient.m", 
                filePath + "RPCClient.m",
                false));

        return result;
    }

    @Override
    public List<IUpdater> getRestEntityUpdaters(EntityMetadata entity) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<IUpdater> getRestUpdatersTest() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<IUpdater> getRestEntityUpdatersTest(EntityMetadata entity) {
        // TODO Auto-generated method stub
        return null;
    }

}
