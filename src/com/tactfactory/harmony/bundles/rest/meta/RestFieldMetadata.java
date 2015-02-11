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
import java.util.Locale;
import java.util.Map;

import com.google.common.base.CaseFormat;
import com.tactfactory.harmony.meta.BaseMetadata;
import com.tactfactory.harmony.meta.ClassMetadata;
import com.tactfactory.harmony.meta.EnumTypeMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata.Group;
import com.tactfactory.harmony.platform.IAdapter;

/**
 * Metadata for Bundle Rest Field.
 */
public class RestFieldMetadata extends BaseMetadata {
    /** Owner. */
    private ClassMetadata owner;

    /** Enum type metadata. */
    private EnumTypeMetadata enumMeta;
    
    /**
     * Constructor.
     * @param owner ClassMetadata owning this field.
     */
    public RestFieldMetadata(final ClassMetadata owner) {
        super();
        this.owner = owner;
    }

    /** Add Component String of field.
     * @param componentName The component name
     */
    public final void makeString(final String componentName) {
        final String key =
                this.owner.getName().toLowerCase()
                + "_"
                + this.getName().toLowerCase();

        TranslationMetadata.addDefaultTranslation(
                key + "_" + componentName.toLowerCase(Locale.ENGLISH),
                CaseFormat.LOWER_CAMEL.to(
                        CaseFormat.UPPER_CAMEL, this.getName()),
                        Group.MODEL);
    }

    /**
     * Transform the field to a map of strings and a relation map.
     * @param adapter The adapter to use.
     * @return the map
     */
    @Override
    public final Map<String, Object> toMap(final IAdapter adapter) {
        final Map<String, Object> model = new HashMap<String, Object>();
        model.put("name",         this.getName());

        return model;
    }

    /**
     * @return the owner
     */
    public final ClassMetadata getOwner() {
        return owner;
    }

    /**
     * @param owner the owner to set
     */
    public final void setOwner(final ClassMetadata owner) {
        this.owner = owner;
    }
    
    @Override
    public String toString() {
        return String.format("FieldMetadata : %s", this.getName());
    }

    /**
     * @return the enumMeta
     */
    public final EnumTypeMetadata getEnumMeta() {
        return enumMeta;
    }

    /**
     * @param enumMeta the enumMeta to set
     */
    public final void setEnumMeta(final EnumTypeMetadata enumMeta) {
        this.enumMeta = enumMeta;
    }
}
