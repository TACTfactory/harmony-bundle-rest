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
import java.util.Map;

import com.tactfactory.harmony.meta.BaseMetadata;
import com.tactfactory.harmony.meta.ClassMetadata;
import com.tactfactory.harmony.platform.IAdapter;

/**
 * Metadata for Bundle Rest Field.
 */
public class RestFieldMetadata extends BaseMetadata {
    /** restName The new rest name to set. */
    private String restName;

    /**
     * Constructor.
     * @param owner ClassMetadata owning this field.
     */
    public RestFieldMetadata(final ClassMetadata owner) {
        super();
        this.setName("rest");
    }

    /**
     * Transform the field to a map of strings and a relation map.
     * @param adapter The adapter to use.
     * @return the map
     */
    @Override
    public final Map<String, Object> toMap(final IAdapter adapter) {
        final Map<String, Object> model = new HashMap<String, Object>();
        model.put("name",         this.getRestName());

        return model;
    }

    /**
     * @return restName The rest name.
     */
    public String getRestName() {
        return restName;
    }

    /**
     * Set rest name.
     * @param restName Rest name to set
     */
    public void setRestName(String restName) {
        this.restName = restName;
    }
}
