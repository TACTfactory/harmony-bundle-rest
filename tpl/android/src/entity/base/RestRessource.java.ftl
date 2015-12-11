<@header?interpret />
package ${entity_namespace}.base;

import ${entity_namespace}.base.Resource;

import java.io.Serializable;

import org.joda.time.DateTime;

public interface RestResource extends Resource {
    /**
     * @return the local path
     */
    String getLocalPath();

    /**
     * @param value the local path to set
     */
    void setLocalPath(final String value);
}