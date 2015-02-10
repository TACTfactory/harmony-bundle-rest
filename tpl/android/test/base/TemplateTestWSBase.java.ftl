<@header?interpret />
<#include utilityPath + "all_imports.ftl" />
package ${test_namespace}.base;

import java.util.ArrayList;

import android.database.Cursor;

import ${project_namespace}.data.${curr.name}WebServiceClientAdapter;
import ${project_namespace}.data.RestClient.RequestConstants;
import ${project_namespace}.entity.${curr.name};
<#list InheritanceUtils.getAllChildren(curr) as child>
import ${fixture_namespace}.${child.name?cap_first}DataLoader;
</#list>
import ${test_namespace}.utils.${curr.name}Utils;
import ${test_namespace}.utils.TestUtils;

import com.google.mockwebserver.MockResponse;

import junit.framework.Assert;

/** ${curr.name} Web Service Test.
 * 
 * @see android.app.Fragment
 */
public abstract class ${curr.name}TestWSBase extends TestWSBase {
    /** model {@link ${curr.name}}. */
    protected ${curr.name} model;
    /** web {@link ${curr.name}WebServiceClientAdapter}. */
    protected ${curr.name}WebServiceClientAdapter web;
    /** entities ArrayList<${curr.name}>. */
    protected ArrayList<${curr.name}> entities;
    /** nbEntities Number of entities. */
    protected int nbEntities = 0;

    @Override
    protected void setUp() throws Exception {
        super.setUp();

        String host = this.server.getHostName();
        int port = this.server.getPort();

        this.web = new ${curr.name}WebServiceClientAdapter(
            this.ctx, host, port, RequestConstants.HTTP);
        
        this.entities = new ArrayList<${curr.name?cap_first}>();        
        <#list InheritanceUtils.getAllChildren(curr) as child>
        this.entities.addAll(${child.name?cap_first}DataLoader.getInstance(this.ctx).getMap().values());
        </#list>
        
        if (entities.size() > 0) {
            this.model = this.entities.get(TestUtils.generateRandomInt(0,entities.size()-1));
        }

        <#list InheritanceUtils.getAllChildren(curr) as child>
        this.nbEntities += ${child.name?cap_first}DataLoader.getInstance(this.ctx).getMap().size();
        </#list>
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
    
    /** Test case Get Entity. */
    public void testGet() {
        this.server.enqueue(new MockResponse().setBody(
            this.web.itemToJson(this.model).toString()));

        int result = this.web.get(this.model);

        Assert.assertTrue(result >= 0);
    }

    /** Test case Read Entity. */
    public void testQuery() {
        this.server.enqueue(new MockResponse().setBody(
            this.web.itemToJson(this.model).toString()));

        Cursor result = this.web.query(<#list curr_ids as id>this.model.get${id.name?cap_first}()<#if id_has_next>,
                </#if></#list>);
        
        Assert.assertTrue(result.getCount() >= 0);
    }

    /** Test case get all Entity. */
    public void testGetAll() {
        this.server.enqueue(new MockResponse().setBody("{${curr.name}s :"
            + this.web.itemsToJson(this.entities).toString() + "}"));

        ArrayList<${curr.name}> ${curr.name?uncap_first}List = 
                        new ArrayList<${curr.name}>();
        int result = this.web.getAll(${curr.name?uncap_first}List);

        Assert.assertEquals(${curr.name?uncap_first}List.size(), this.entities.size());
    }
    
    /** Test case Update Entity. */
    public void testUpdate() {
        this.server.enqueue(new MockResponse().setBody("{'result'='1'}"));

        int result = this.web.update(this.model);

        Assert.assertTrue(result >= 0);
        
        this.server.enqueue(new MockResponse().setBody(
            this.web.itemToJson(this.model).toString()));

        ${curr.name} item = new ${curr.name}();
        <#list curr_ids as id>
        item.set${id.name?cap_first}(this.model.get${id.name?cap_first}());
        </#list>

        result = this.web.get(item);
        <#if (curr.options.sync??)>
        
        ${curr.name}Utils.equals(this.model, item, false);
        <#else>
        
        ${curr.name}Utils.equals(this.model, item);
        </#if>
    }
    
    /** Test case Delete Entity. */
    public void testDelete() {
        this.server.enqueue(new MockResponse().setBody("{'result'='1'}"));

        int result = this.web.delete(this.model);

        Assert.assertTrue(result == 0);

        this.server.enqueue(new MockResponse().setBody("{}"));

        result = this.web.get(this.model);

        Assert.assertTrue(result < 0);
    }
}
