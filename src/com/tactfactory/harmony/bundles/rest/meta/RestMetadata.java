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

import com.tactfactory.harmony.bundles.rest.annotation.Rest.Security;
import com.tactfactory.harmony.meta.BaseMetadata;
import com.tactfactory.harmony.plateforme.IAdapter;

/**
 * Metadata for Bundle Rest.
 */
public class RestMetadata extends BaseMetadata {
	/** Bundle name. */
	public static final String NAME = "rest";
	/** Bundle enable state. */
	private boolean isEnabled = false;
	/** Security level. */
	private Security security = Security.NONE;
	/** URI. */
	private String uri;
	/** DateFormat. */
	private String dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
	
	/**
	 * Constructor.
	 */
	public RestMetadata() {
		super();
		this.setName(NAME);
	}
	
	
	@Override
	public final HashMap<String, Object> toMap(final IAdapter adapter) {
		final HashMap<String, Object> ret = new HashMap<String, Object>();
		
		ret.put("isEnabled", this.isEnabled);
		ret.put("uri", this.uri);
		ret.put("security", this.security.getValue());
		ret.put("dateFormat", this.dateFormat);
		
		return ret;
	}


	/**
	 * @return the isEnabled
	 */
	public final boolean isEnabled() {
		return isEnabled;
	}


	/**
	 * @param isEnabled the isEnabled to set
	 */
	public final void setEnabled(final boolean isEnabled) {
		this.isEnabled = isEnabled;
	}


	/**
	 * @return the security
	 */
	public final Security getSecurity() {
		return security;
	}


	/**
	 * @param security the security to set
	 */
	public final void setSecurity(final Security security) {
		this.security = security;
	}


	/**
	 * @return the uri
	 */
	public final String getUri() {
		return uri;
	}


	/**
	 * @param uri the uri to set
	 */
	public final void setUri(final String uri) {
		this.uri = uri;
	}
	
	/**
	 * @param dateFormat The rest date format
	 */
	public final void setDateFormat(final String dateFormat) {
		this.dateFormat = dateFormat;
	}
	
	/**
	 * @return The rest date format
	 */
	public final String getDateFormat() {
		return this.dateFormat;
	}
}
