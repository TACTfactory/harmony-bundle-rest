/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.platform.android;

import java.util.ArrayList;
import java.util.List;

import com.tactfactory.harmony.bundles.rest.platform.RestAdapter;
import com.tactfactory.harmony.bundles.rest.platform.android.updater.AddImplementsRestAndroid;
import com.tactfactory.harmony.generator.androidxml.ManifestUpdater;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.platform.android.AndroidAdapter;
import com.tactfactory.harmony.platform.android.updater.ManifestPermissionAndroid;
import com.tactfactory.harmony.updater.IUpdater;
import com.tactfactory.harmony.updater.impl.SourceFile;

/**
 * RestAdapter Adapter for Android.
 * @author Erwan Le Huitouze (erwan.lehuitouze@tactfactory.com)
 *
 */
public class RestAdapterAndroid extends AndroidAdapter implements RestAdapter {

    @Override
    public List<IUpdater> getRestUpdaters() {
        List<IUpdater> result = new ArrayList<IUpdater>();

        List<String> libraries = new ArrayList<String>();
        libraries.add("bundle-rest-annotations.jar");
        libraries.add("httpmime-4.1.1.jar");

        result.addAll(this.getLibrariesCopyFile(libraries));

        result.add(new ManifestPermissionAndroid(
                this, ManifestUpdater.Permissions.INTERNET));

        result.add(new ManifestPermissionAndroid(
                this, ManifestUpdater.Permissions.ACCESS_NETWORK_STATE));

        String templatePath = this.getTemplateSourceDataPath();
        String filePath = this.getSourcePath()
                + this.getApplicationMetadata().getProjectNameSpace()
                + "/" + this.getData() + "/";

        result.add(new SourceFile(
                templatePath + "base/WebServiceClientAdapterBase.java",
                filePath + "base/WebServiceClientAdapterBase.java",
                true));

        // Make Abstract Adapter Base general for all entities
        result.add(new SourceFile(
                templatePath + "WebServiceClientAdapter.java",
                filePath + "WebServiceClientAdapter.java",
                false));

        result.add(new SourceFile(
                templatePath + "base/ResourceWebServiceClientAdapterBase.java",
                filePath + "base/ResourceWebServiceClientAdapterBase.java",
                true));

        result.add(new SourceFile(
                templatePath + "ResourceWebServiceClientAdapter.java",
                filePath + "ResourceWebServiceClientAdapter.java",
                false));

        result.add(new SourceFile(
                templatePath + "RestClient.java",
                filePath + "RestClient.java",
                false));

        templatePath = this.getTemplateSourceEntityBasePath();
        filePath = this.getSourcePath()
                + this.getApplicationMetadata().getProjectNameSpace()
                + "/" + this.getModel() + "/";

        result.add(new SourceFile(
                templatePath + "RestResource.java",
                filePath + "base/RestResource.java",
                true));

        return result;
    }

    @Override
    public List<IUpdater> getRestEntityUpdaters(EntityMetadata entity) {
        List<IUpdater> result = new ArrayList<IUpdater>();

        String templatePath = this.getTemplateSourceDataPath();
        String filePath = this.getSourcePath()
                + this.getApplicationMetadata().getProjectNameSpace()
                + "/" + this.getData() + "/";

        result.add(new SourceFile(
                templatePath + "base/TemplateWebServiceClientAdapterBase.java",
                filePath + "base/" + entity.getName()
                + "WebServiceClientAdapterBase.java",
                true));
        result.add(new SourceFile(
                templatePath + "TemplateWebServiceClientAdapter.java",
                filePath + entity.getName() + "WebServiceClientAdapter.java",
                false));

        return result;
    }

    @Override
    public List<IUpdater> getRestUpdatersTest() {
        List<IUpdater> result = new ArrayList<IUpdater>();

        List<String> libraries = new ArrayList<String>();
        libraries.add("mockwebserver.jar");

        result.addAll(this.getLibrariesTestCopyFile(libraries));

        String templatePath = this.getTemplateTestsPath();
        String filePath = this.getTestPath()
                + this.getSource() + "/"
                + this.getApplicationMetadata().getProjectNameSpace() + "/"
                + "test/";

        result.add(new SourceFile(
                templatePath + "base/TestWSBase.java",
                filePath + "base/TestWSBase.java",
                true));

        return result;
    }

    @Override
    public List<IUpdater> getRestEntityUpdatersTest(EntityMetadata entity) {
        List<IUpdater> result = new ArrayList<IUpdater>();

        String templatePath = this.getTemplateTestsPath();
        String filePath = this.getTestPath()
                + this.getSource() + "/"
                + this.getApplicationMetadata().getProjectNameSpace() + "/"
                + "test/";

        result.add(new SourceFile(
                templatePath + "base/TemplateTestWSBase.java",
                String.format("%sbase/%sTestWSBase.java",
                        filePath, entity.getName()),
                        true));

        result.add(new SourceFile(
                templatePath + "TemplateTestWS.java",
                String.format("%s%sTestWS.java",
                        filePath, entity.getName()),
                        false));

        return result;
    }

    @Override
    public List<IUpdater> getEntityResourceUpdaters(EntityMetadata entity) {
        List<IUpdater> result = new ArrayList<IUpdater>();

        if (!entity.isInternal()) {
            result.add(new AddImplementsRestAndroid(this, entity));
        }

        return result;
    }

}
