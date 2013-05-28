<#assign curr = entities[current_entity] />
package ${test_namespace}.base;

import ${test_namespace}.*;


import ${project_namespace}.data.${curr.name}WebServiceClientAdapter;
import ${project_namespace}.entity.${curr.name};
import ${test_namespace}.utils.${curr.name}Utils;

import com.google.mockwebserver.MockResponse;
import com.google.mockwebserver.MockWebServer;
import android.content.Context;
import android.test.AndroidTestCase;

import junit.framework.Assert;

/** ${curr.name} Web Service Test
 * 
 * @see android.app.Fragment
 */
public class ${curr.name}TestWSBase extends AndroidTestCase {
	private Context ctx;
	private ${curr.name} model;
	private ${curr.name}WebServiceClientAdapter web;
	private MockWebServer server;

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#setUp()
	 */
	protected void setUp() throws Exception {
		super.setUp();
		this.ctx = this.getContext();

		this.server = new MockWebServer();
		this.server.play();

		String host = this.server.getHostName();
		int port = this.server.getPort();

		this.web = new ${curr.name}WebServiceClientAdapter(this.ctx, host, port);
		
		this.model = ${curr.name}Utils.generateRandom(this.ctx);
	}

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#tearDown()
	 */
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	/* (non-Javadoc)
	 * @see ${curr.name}Ws#login(Account)
	 */
	/*public void authentificate() {		
		int result = this.ws.login(this.me);
		Assert.assertEquals(0, result);
	}*/
	
	/** Test case Create Entity */
	public void testCreate() {
		this.server.enqueue(new MockResponse().setBody("{'result'='0'}"));

		int result = this.web.insert(this.model);
		Assert.assertTrue(result >= 0);
	}
	
	/** Test case Read Entity */
	public void testRead() {
		this.server.enqueue(new MockResponse().setBody(
			this.web.itemToJson(this.model).toString()));
		int result = this.web.get(this.model); // TODO Generate by @Id annotation
		Assert.assertTrue(result >= 0);
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
