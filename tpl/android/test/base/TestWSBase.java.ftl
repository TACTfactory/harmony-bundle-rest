<#assign curr = entities[current_entity] />
package ${test_namespace}.base;


<#if (curr.options.sync??)>
import ${test_namespace}.utils.TestUtils;</#if>

import com.google.mockwebserver.MockResponse;
import com.google.mockwebserver.MockWebServer;
import android.content.Context;

import junit.framework.Assert;

/**
 * Web Service Test Base.
 */
public abstract class TestWSBase extends TestDBBase {
	protected Context ctx;
	protected MockWebServer server;

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#setUp()
	 */
	protected void setUp() throws Exception {
		super.setUp();
		this.ctx = this.getContext();

		this.server = new MockWebServer();
		this.server.play();
	}

	/* (non-Javadoc)
	 * @see junit.framework.TestCase#tearDown()
	 */
	protected void tearDown() throws Exception {
		super.tearDown();
		this.server.shutdown();
	}
}
