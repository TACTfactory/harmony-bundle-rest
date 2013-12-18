/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.template;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;

import com.tactfactory.harmony.meta.ConfigMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata;
import com.tactfactory.harmony.meta.TranslationMetadata.Group;
import com.tactfactory.harmony.plateforme.BaseAdapter;
import com.tactfactory.harmony.template.BaseGenerator;
import com.tactfactory.harmony.template.ConfigGenerator;
import com.tactfactory.harmony.template.TagConstant;
import com.tactfactory.harmony.template.TranslationGenerator;
import com.tactfactory.harmony.template.androidxml.ManifestUpdater;
import com.tactfactory.harmony.utils.ConsoleUtils;
import com.tactfactory.harmony.utils.TactFileUtils;

/**
 * Generator for bundle Rest.
 */
public class RestGenerator extends BaseGenerator {

	/**
	 * Constructor.
	 * @param adapter The used adapter.
	 * @throws Exception 
	 */
	public RestGenerator(final BaseAdapter adapter) throws Exception {
		super(adapter);
		this.setDatamodel(this.getAppMetas().toMap(this.getAdapter()));
	}
	
	/**
	 * Generates everything.
	 */
	public final void generateAll() {
		// Import Bundle for annotation
		this.updateLibrary("bundle-rest-annotations.jar");
				
		this.generateWSAdapter();
		try {
			new TestWSGenerator(this.getAdapter()).generateAll();
			
		} catch (final Exception e) {
			ConsoleUtils.displayError(e);
		}
	}
	
	/**
	 * Generate WebService Adapter.
	 */
	protected final void generateWSAdapter() {
		// Add internet permission to manifest :
		ManifestUpdater manifest = new ManifestUpdater(this.getAdapter());
		manifest.addPermission(ManifestUpdater.Permissions.INTERNET);
		manifest.addPermission(
				ManifestUpdater.Permissions.ACCESS_NETWORK_STATE);
		manifest.save();
		
		this.updateLibrary("httpmime-4.1.1.jar");
		this.updateLibrary("mockwebserver.jar");
		
		TranslationMetadata.addDefaultTranslation(
				"common_network_error", "Connection error", Group.COMMON);
		
		TranslationMetadata.addDefaultTranslation(
				"no_network_error", "No internet connection available", Group.COMMON);
		
		ConfigMetadata.addConfiguration(
				"rest_url_prod", "http://127.0.0.1:80/api/");
		ConfigMetadata.addConfiguration(
				"rest_url_dev", "http://127.0.0.1:80/api_dev/");
		
		ConfigMetadata.addConfiguration("rest_check_ssl", "true");
		ConfigMetadata.addConfiguration("rest_ssl", "ca.cert");

		// Make Abstract Adapter Base general for all entities
		this.makeSource(
				"base/WebServiceClientAdapterBase.java", 
				"base/WebServiceClientAdapterBase.java",
				true);

		// Make Abstract Adapter Base general for all entities
		this.makeSource(
				"WebServiceClientAdapter.java", 
				"WebServiceClientAdapter.java",
				false);
		
		// Make RestClient
		this.makeSource(
				"RestClient.java", 
				"RestClient.java",
				false);
		
		for (final EntityMetadata entityMeta
				: this.getAppMetas().getEntities().values()) {
			if (entityMeta.getOptions().get("rest") != null
					&& !entityMeta.getFields().isEmpty()) {
				this.getDatamodel().put(
						TagConstant.CURRENT_ENTITY, entityMeta.getName());
				this.makeSource(
						"base/TemplateWebServiceClientAdapterBase.java", 
						"base/" + entityMeta.getName() 
							+ "WebServiceClientAdapterBase.java", 
						true);
				this.makeSource(
						"TemplateWebServiceClientAdapter.java", 
						entityMeta.getName() + "WebServiceClientAdapter.java", 
						false);
			}
		}	
		try {
			new TranslationGenerator(this.getAdapter()).generateStringsXml();
			new ConfigGenerator(this.getAdapter()).generateConfigXml();
		} catch (final Exception e) {
			// TODO Auto-generated catch block
			ConsoleUtils.displayError(e);
		}
	}
		
	@Override
	protected final void makeSource(final String templateName, 
			final String fileName, 
			final boolean override) {
		final String fullFilePath = 
				this.getAdapter().getSourcePath() 
				+ this.getAppMetas().getProjectNameSpace() 
				+ "/" + this.getAdapter().getData() + "/"
				+ fileName;
		final String fullTemplatePath = 
				this.getAdapter().getTemplateSourceProviderPath()
				+ templateName;
		
		super.makeSource(fullTemplatePath, fullFilePath, override);
	}
}
