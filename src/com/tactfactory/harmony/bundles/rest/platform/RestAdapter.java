/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.platform;

import java.util.List;

import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.plateforme.IAdapter;
import com.tactfactory.harmony.updater.IUpdater;

/**
 * Interface for RestAdapter.
 * @author Erwan Le Huitouze (erwan.lehuitouze@tactfactory.com)
 *
 */
public interface RestAdapter extends IAdapter {
    /**
     * 
     * @return List of {@link IUpdater} for global Rest files
     */
    List<IUpdater> getRestUpdaters();
    
    /**
     * 
     * @param entity {@link EntityMetadata} for generate its specifics files
     * @return List of {@link IUpdater} for entity Rest files
     */
    List<IUpdater> getRestEntityUpdaters(EntityMetadata entity);
    
    /**
     * 
     * @return List of {@link IUpdater} for global test Rest files
     */
    List<IUpdater> getRestUpdatersTest();
    
    /**
     * 
     * @param entity {@link EntityMetadata} for generate its specifics files
     * @return List of {@link IUpdater} for entity test Rest files
     */
    List<IUpdater> getRestEntityUpdatersTest(EntityMetadata entity);
}
