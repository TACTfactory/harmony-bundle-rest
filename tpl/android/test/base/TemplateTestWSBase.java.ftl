<#assign curr = entities[current_entity] />
package ${test_namespace}.base;

import java.util.ArrayList;

import android.database.Cursor;

import ${project_namespace}.data.${curr.name}WebServiceClientAdapter;
import ${project_namespace}.data.RestClient.RequestConstants;
import ${project_namespace}.entity.${curr.name};
import ${project_namespace}.fixture.${curr.name}DataLoader;
import ${test_namespace}.utils.${curr.name}Utils;
import ${test_namespace}.utils.TestUtils;

import com.google.mockwebserver.MockResponse;

import junit.framework.Assert;

/** ${curr.name} Web Service Test
 * 
 * @see android.app.Fragment
 */
public abstract class ${curr.name}TestWSBase extends TestWSBase {
	protected ${curr.name} model;
	protected ${curr.name}WebServiceClientAdapter web;
	protected ArrayList<${curr.name}> entities;

	@Override
	protected void setUp() throws Exception {
		super.setUp();

		String host = this.server.getHostName();
		int port = this.server.getPort();

		this.web = new ${curr.name}WebServiceClientAdapter(
			this.ctx, host, port, RequestConstants.HTTP);
		
		this.entities = new ArrayList<${curr.name?cap_first}>(${curr.name?cap_first}DataLoader.getInstance(this.ctx).getMap().values());
		if (this.entities.size()>0) {
			this.model = this.entities.get(TestUtils.generateRandomInt(0,entities.size()-1));
		}
		<#if (curr.options.sync??)>
		this.model.setServerId(TestUtils.generateRandomInt(1, 200));
		</#if>
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	/** Test case Create Entity */
	public void testInsert() {
		this.server.enqueue(new MockResponse().setBody("{'result'='0'}"));

		int result = this.web.insert(this.model);
		Assert.assertTrue(result >= 0);
	}
	
	/** Test case Get Entity */
	public void testGet() {
		this.server.enqueue(new MockResponse().setBody(
			this.web.itemToJson(this.model).toString()));
		int result = this.web.get(this.model);
		Assert.assertTrue(result >= 0);
	}

	/** Test case Read Entity */
	public void testQuery() {
		this.server.enqueue(new MockResponse().setBody(
			this.web.itemToJson(this.model).toString()));
		Cursor result = this.web.query(String.valueOf(this.model.getId()));
		
		Assert.assertTrue(result.getCount() >= 0);
	}

	/** Test case get all Entity */
	public void testGetAll() {
		this.server.enqueue(new MockResponse().setBody(
			this.web.itemToJson(this.model).toString()));
		ArrayList<${curr.name}> ${curr.name?uncap_first}List = 
						new ArrayList<${curr.name}>();
		int result = this.web.getAll(${curr.name?uncap_first}List);
		Assert.assertEquals(${curr.name?uncap_first}List.size(), this.entities.size());
	}
	
	/** Test case Update Entity */
	public void testUpdate() {
		this.server.enqueue(new MockResponse().setBody("{'result'='1'}"));
		
		int result = this.web.update(this.model);
		Assert.assertTrue(result >= 0);
		
		this.server.enqueue(new MockResponse().setBody(
			this.web.itemToJson(this.model).toString()));

		${curr.name} item = new ${curr.name}();
		item.setId(this.model.getId());

		result = this.web.get(item);
		${curr.name}Utils.equals(this.model, item);
	}
	
	/** Test case Update Entity */
	public void testDelete() {
		this.server.enqueue(new MockResponse().setBody("{'result'='1'}"));
		int result = this.web.delete(this.model);
		Assert.assertTrue(result == 0);		

		this.server.enqueue(new MockResponse().setBody("{}"));

		result = this.web.get(this.model);
		Assert.assertTrue(result < 0);
	}
}
