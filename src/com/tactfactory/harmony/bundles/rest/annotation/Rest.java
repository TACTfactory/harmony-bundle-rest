/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.annotation;

import static java.lang.annotation.ElementType.TYPE;
import static java.lang.annotation.RetentionPolicy.SOURCE;

import java.lang.annotation.Documented;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import java.lang.reflect.Field;

import com.tactfactory.harmony.utils.ConsoleUtils;

/**
 * To mark a entity for remote/central 
 * persistence/access the @Rest annotation is used.
 */
@Documented
@Retention(SOURCE)
@Target(TYPE)
@Inherited
public @interface Rest {
	
	/** Security access of REST query. */
	public enum Security {
		/** No Security. */
		NONE(0),
		/** Session Security. */
		SESSION(1);
		
		/** Security id. */
		private int value;
		
		/** 
		 * Constructor.
		 * @param v Security id.
		 */
		private Security(final int v) {
			this.value = v;
		}
		
		/**
		 * Get Security id.
		 * @return The security id
		 */
		public int getValue() {
			return this.value;
		}
		
		/**
		 * Retrieve Security from given id.
		 * @param value The id
		 * @return The found Security. Null if no Security found.
		 */
		public static Security fromValue(final int value) {
			Security ret = null;
				for (final Security type : Security.values()) {
					if (value == type.value) {
						ret = type;
					}    
				}
			
			return ret;
		}
		
		/**
		 * Retrieves the Security by its enum name. (reflection)
		 * @param name The Security enum name.
		 * @return The security
		 */
		public static Security fromName(final String name) {
			String realName;
			Security ret;
			if (name.lastIndexOf('.') > 0) {
				// Take only what comes after the last dot
				realName = name.substring(name.lastIndexOf('.') + 1); 
			} else {
				realName = name;
			}
			ConsoleUtils.displayDebug("Searching for Security : " + realName);
			try {
				final Field field = Security.class.getField(realName);	
				if (field.isEnumConstant()) {
					ConsoleUtils.displayDebug("Found Security : " + realName);
					ret = (Security) field.get(Security.class);
				} else {
					ret = null;
				}
			} catch (final NoSuchFieldException e) {
				ret = null;
			} catch (final IllegalAccessException e) {
				ret = null;				
			}
			
			return ret;
		}
	}
	
	/**
	 * The uri for entity.
	 */
	String uri() default "";
	
	/**
	 * The security level.
	 */
	Security security() default Security.NONE;
	
	/**
	 * Format for dates in rest communication.
	 */
	String dateFormat() default "";
}
