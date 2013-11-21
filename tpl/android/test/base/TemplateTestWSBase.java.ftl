<#assign curr = entities[current_entity] />
package ${test_namespace}.base;


import ${project_namespace}.data.${curr.name}WebServiceClientAdapter;
import ${project_namespace}.entity.${curr.name};
import ${test_namespace}.utils.${curr.name}Utils;<#if (curr.options.sync??)>
import ${test_namespace}.utils.TestUtils;</#if>

import com.google.mockwebserver.MockResponse;

import junit.framework.Assert;

/** ${curr.name} Web Service Test
 * 
 * @see android.app.Fragment
 */
public abstract class ${curr.name}TestWSBase extends TestWSBase {
	protected ${curr.name} model;
	protected ${curr.name}WebServiceClientAdapter web;

	@Override
	protected void setUp() throws Exception {
		super.setUp();

		String host = this.server.getHostName();
		int port = this.server.getPort();

		this.web = new ${curr.name}WebServiceClientAdapter(
			this.ctx, host, port);
		
		this.model = ${curr.name}Utils.generateRandom(this.ctx);
		<#if (curr.options.sync??)>
		this.model.setServerId(TestUtils.generateRandomInt(1, 200));
		</#if>
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
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
		int result = this.web.get(this.model);
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
