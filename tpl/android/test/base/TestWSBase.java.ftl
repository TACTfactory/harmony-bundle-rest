<@header?interpret />
package ${test_namespace}.base;


import com.google.mockwebserver.MockWebServer;
import android.content.Context;

/**
 * Web Service Test Base.
 */
public abstract class TestWSBase extends TestDBBase {
    /** Android {@link Context}. */
    protected Context ctx;
    /** {@link MockWebServer}. */
    protected MockWebServer server;

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        this.ctx = this.getContext();

        this.server = new MockWebServer();
        this.server.play();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        this.server.shutdown();
    }
}
