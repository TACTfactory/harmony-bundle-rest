/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.meta;

import java.util.HashMap;
import java.util.LinkedHashMap;

import com.tactfactory.harmony.meta.BaseMetadata;
import com.tactfactory.harmony.meta.ClassMetadata;
import com.tactfactory.harmony.plateforme.BaseAdapter;
import com.tactfactory.harmony.template.TagConstant;

/**
 * Rest metadata at application level.
 */
public class ApplicationRestMetadata extends BaseMetadata {
	/** Bundle name. */
	private static final String NAME = "rest";
	/** Rest entities. */
	private LinkedHashMap<String, ClassMetadata> entities = 
			new LinkedHashMap<String, ClassMetadata>();
	
	/**
	 * Constructor.
	 */
	public ApplicationRestMetadata() {
		super();
		this.setName(NAME);
	}
	
	@Override
	public final HashMap<String, Object> toMap(final BaseAdapter adapter) {
		final HashMap<String, Object> ret = new HashMap<String, Object>();
		final HashMap<String, Object> entitiesMap = 
				new HashMap<String, Object>();
		for (final ClassMetadata cm : this.entities.values()) {
			entitiesMap.put(cm.getName(), cm.toMap(adapter));
		}
		ret.put(TagConstant.ENTITIES, entitiesMap);
		
		return ret;
	}
}
