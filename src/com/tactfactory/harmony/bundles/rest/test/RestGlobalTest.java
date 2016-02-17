package com.tactfactory.harmony.bundles.rest.test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import com.tactfactory.harmony.Harmony;
import com.tactfactory.harmony.bundles.rest.command.RestCommand;
import com.tactfactory.harmony.bundles.rest.meta.RestMetadata;
import com.tactfactory.harmony.bundles.rest.test.factory.RestDemactFactory;
import com.tactfactory.harmony.bundles.rest.test.factory.RestManagementFactory;
import com.tactfactory.harmony.command.FixtureCommand;
import com.tactfactory.harmony.command.OrmCommand;
import com.tactfactory.harmony.command.ProjectCommand;
import com.tactfactory.harmony.meta.ApplicationMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.test.CommonTest;
import com.tactfactory.harmony.test.factory.ProjectMetadataFactory;
import com.tactfactory.harmony.utils.ConsoleUtils;
import com.tactfactory.harmony.utils.TactFileUtils;

/**
 * Tests for Rest bundle generation.
 */
@RunWith(Parameterized.class)
public class RestGlobalTest extends CommonTest {
    /** Path of entity folder. */
    private static final String ENTITY_PATH = "android/src/%s/entity/%s.java";

    /** Path of data folder. */
    private static final String DATA_PATH = "android/src/%s/data/%s.java";

    public RestGlobalTest(ApplicationMetadata currentMetadata) throws Exception {
        super(currentMetadata);
    }

    @Before
    @Override
    public final void setUp() throws RuntimeException {
        super.setUp();
    }

    @After
    @Override
    public final void tearDown() throws RuntimeException {
        super.tearDown();
    }

    @Override
    public void setUpBeforeNewParameter() throws Exception {
        super.setUpBeforeNewParameter();

        // Clean folder
        CommonTest.cleanAndroidFolder(false);

        initAll();
    }

    /**
     * JUnit Parameters method.
     * This should return the various application metadata associated
     * to your various test projects. (ie. Demact, Tracscan, etc.)
     *
     * @return The collection of application metadatas.
     */
    @Parameters
    public static Collection<Object[]> getParameters() {
        return new RestTestConfiguration().getParameters();
    }

    /**
     * Rest Test Configuration class wich expose parameters for test runner.
     *
     * @author Erwan Le Huitouze (erwan.lehuitouze@tactfactory.com)
     *
     */
    protected static class RestTestConfiguration extends CommonTestConfiguration {
        @Override
        protected List<Class<? extends ProjectMetadataFactory>> getFactories() {
            List<Class<? extends ProjectMetadataFactory>> result =
                    new ArrayList<Class<? extends ProjectMetadataFactory>>();

//            result.add(RestTracScanFactory.class);
            result.add(RestDemactFactory.class);
            result.add(RestManagementFactory.class);

            return result;
        }
    }

    /**
     * Test initialization.
     */
    private static void initAll() {
        ConsoleUtils.display("\nTest Rest generate adapters" + SHARP_DELIMITOR);

        getHarmony().findAndExecute(ProjectCommand.INIT_ANDROID, null, null);
        makeEntities();
        getHarmony().findAndExecute(OrmCommand.GENERATE_ENTITIES, new String[] {}, null);
        getHarmony().findAndExecute(OrmCommand.GENERATE_CRUD, new String[] {}, null);
        getHarmony().findAndExecute(FixtureCommand.FIXTURE_INIT, new String[] {}, null);
        getHarmony().findAndExecute(RestCommand.GENERATE_ADAPTERS, new String[] {}, null);

        final RestCommand command = (RestCommand) Harmony.getInstance().getCommand(RestCommand.class);
        command.generateMetas();

        parsedMetadata = ApplicationMetadata.INSTANCE;
    }

    /**
     * Test all imports of entities.
     */
    @Test
    public final void testImport() {
        for (EntityMetadata entity : this.currentMetadata.getEntities().values()) {
            EntityMetadata parsedEntity = parsedMetadata.getEntities().get(entity.getName());

            for (String impor : entity.getImports()) {
                Assert.assertTrue(
                        String.format(
                                "Import : %s should import %s in project %s",
                                entity.getName(),
                                impor,
                                this.currentMetadata.getName()),
                        parsedEntity.getImports().contains(impor));
            }

            Assert.assertEquals(
                    String.format(
                            "Import : %s has a wrong number of imports in project %s",
                            entity.getName(),
                            this.currentMetadata.getName()),
                    entity.getImports().size(),
                    parsedEntity.getImports().size());
        }
    }

    /**
     * Test all EntityMetadata, compare metadata from test factory
     * with metadata from parsed files.
     */
    @Test
    public final void testEntities() {
        for (EntityMetadata entity : this.currentMetadata.getEntities().values()) {
            EntityMetadata parsedEntity = parsedMetadata.getEntities().get(entity.getName());

            Assert.assertNotNull(
                    String.format(
                            "Entity %s not found in project : %s.",
                            entity.getName(),
                            this.currentMetadata.getName()),
                    parsedEntity);

            if (!entity.isInternal()) {
                CommonTest.hasFindFile(String.format(
                        ENTITY_PATH,
                        this.currentMetadata.getProjectNameSpace(),
                        entity.getName()));
            }

            RestMetadata currentRestMetadata = (RestMetadata) entity.getOptions().get(RestMetadata.NAME);

            if (currentRestMetadata != null) {
                RestMetadata parsedRestMetadata = (RestMetadata) parsedEntity.getOptions().get(RestMetadata.NAME);

                Assert.assertNotNull(
                        String.format("Entity %s must have rest annotation", entity.getName()),
                        parsedRestMetadata);

                Assert.assertEquals(
                        String.format("Entity %s hasn't right rest uri", entity.getName()),
                        currentRestMetadata.getUri(),
                        parsedRestMetadata.getUri());

                Assert.assertEquals(
                        String.format("Entity %s hasn't right rest security", entity.getName()),
                        currentRestMetadata.getSecurity(),
                        parsedRestMetadata.getSecurity());
            }
        }

        Assert.assertEquals(
                String.format(
                        "Found a wrong number of entities in project : %s",
                        this.currentMetadata.getName()),
                this.currentMetadata.getEntities().size(),
                parsedMetadata.getEntities().size());
    }

    /**
     * Tests if web service adapters have been generated.
     */
    @Test
    public void testRepositories() {
        for (EntityMetadata entity : this.currentMetadata.getEntities().values()) {
            if (entity.getOptions().containsKey(RestMetadata.NAME)) {
                CommonTest.hasFindFile(String.format(
                        DATA_PATH,
                        this.currentMetadata.getProjectNameSpace(),
                        entity.getName() + "WebServiceClientAdapter"));

                CommonTest.hasFindFile(String.format(
                        DATA_PATH,
                        this.currentMetadata.getProjectNameSpace(),
                        "base/" + entity.getName()
                        + "WebServiceClientAdapterBase"));
            }
        }
    }

    /**
     * Copy the test entities in the test project.
     */
    protected static void makeEntities() {
        final String pathNameSpace =
                ApplicationMetadata.INSTANCE.getProjectNameSpace()
                .replaceAll("\\.", "/");

        String srcDir = String.format("%s/resources/%s/%s/",
                Harmony.getCommandPath(RestCommand.class),
                pathNameSpace,
                "entity");

        String destDir = String.format("%s/src/%s/%s/",
                Harmony.getProjectAndroidPath(),
                pathNameSpace,
                "entity");

        TactFileUtils.makeFolderRecursive(srcDir, destDir, true);

        if (new File(destDir + "Post.java").exists()) {
            ConsoleUtils.displayDebug("Entity is copy to generated package !");
        }

        srcDir = String.format("%s/resources/%s/%s/%s/",
                Harmony.getCommandPath(RestCommand.class),
                pathNameSpace,
                "fixture",
                "yml");

        destDir = String.format("%s/%s/",
                Harmony.getProjectAndroidPath(),
                "assets");

        TactFileUtils.makeFolderRecursive(srcDir, destDir, true);
    }
}
