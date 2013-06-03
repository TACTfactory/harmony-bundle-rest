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

import com.tactfactory.mda.meta.ConfigMetadata;
import com.tactfactory.mda.meta.EntityMetadata;
import com.tactfactory.mda.meta.TranslationMetadata;
import com.tactfactory.mda.meta.TranslationMetadata.Group;
import com.tactfactory.mda.plateforme.BaseAdapter;
import com.tactfactory.mda.template.BaseGenerator;
import com.tactfactory.mda.template.ConfigGenerator;
import com.tactfactory.mda.template.TagConstant;
import com.tactfactory.mda.template.TranslationGenerator;
import com.tactfactory.mda.utils.ConsoleUtils;
import com.tactfactory.mda.utils.TactFileUtils;

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
		this.addPermissionManifest("android.permission.INTERNET");
		
		this.updateLibrary("httpmime-4.1.1.jar");
		
		TranslationMetadata.addDefaultTranslation(
				"common_network_error", "Connection error", Group.COMMON);
		
		ConfigMetadata.addConfiguration(
				"rest_url_prod", "https://domain.tlk:443/");
		ConfigMetadata.addConfiguration(
				"rest_url_dev", "https://dev.domain.tlk:443/");
		ConfigMetadata.addConfiguration("rest_check_ssl", "true");
		ConfigMetadata.addConfiguration("rest_ssl", "ca.cert");
		
		// Make Abstract Adapter Base general for all entities
		this.makeSource(
				"base/WebServiceClientAdapterBase.java", 
				"base/WebServiceClientAdapterBase.java",
				true);
		
		// Make RestClient
		this.makeSource(
				"RestClient.java", 
				"RestClient.java",
				true);
		
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
						true);
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
	
	/**  Update Android Manifest.
	 * 
	 * @param permissionName The permission to add
	 */
	private void addPermissionManifest(final String permissionName) {
		try { 
			// Make engine
			final SAXBuilder builder = new SAXBuilder();		
			
			// Load XML File
			final File xmlFile = 
					TactFileUtils.makeFile(
							this.getAdapter().getManifestPathFile());
			
			final Document doc = builder.build(xmlFile); 	
			
			// Load Root element
			final Element rootNode = doc.getRootElement(); 			
			
			// Load Name space (required for manipulate attributes)
			final Namespace ns = rootNode.getNamespace("android");	
			Element foundPermission = null;
			// Find Permission Node
			final List<Element> permissions = 
					rootNode.getChildren("uses-permission");
			
			// Find many elements
			for (final Element permission : permissions) {
				if (permission.getAttributeValue("name", ns)
						.equals(permissionName)) {	
					// Load attribute value
					foundPermission = permission;
					break;
				}
			}
			
			// If not found Node, create it
			if (foundPermission == null) {
				// Create new element
				foundPermission = new Element("uses-permission");
				
				// Add Attributes to element
				foundPermission.setAttribute("name", permissionName, ns);	
				rootNode.addContent(foundPermission);
				
				// Write to File
				final XMLOutputter xmlOutput = new XMLOutputter();

				// Make beautiful file with indent !!!
				xmlOutput.setFormat(Format.getPrettyFormat());				
				xmlOutput.output(doc, 
						new OutputStreamWriter(
								new FileOutputStream(xmlFile.getAbsoluteFile()),
								TactFileUtils.DEFAULT_ENCODING));
			}
		} catch (final JDOMException e) {
			ConsoleUtils.displayError(e);
		} catch (final IOException e) {
			ConsoleUtils.displayError(e);
		}
	}
}
