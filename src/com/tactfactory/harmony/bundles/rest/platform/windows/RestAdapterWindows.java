/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.platform.windows;

import java.util.List;

import com.tactfactory.harmony.bundles.rest.platform.RestAdapter;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.platform.windows.WindowsAdapter;
import com.tactfactory.harmony.updater.IUpdater;

/**
 * RestAdapter Adapter for Windows Phone.
 * @author Erwan Le Huitouze (erwan.lehuitouze@tactfactory.com)
 *
 */
public class RestAdapterWindows
        extends WindowsAdapter implements RestAdapter {

    @Override
    public List<IUpdater> getRestUpdaters() {
        // TODO Auto-generated method stub
        return null;
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

    @Override
    public List<IUpdater> getEntityResourceUpdaters(EntityMetadata entity) {
        // TODO Auto-generated method stub
        return null;
    }

}
