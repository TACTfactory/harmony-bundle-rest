package com.tactfactory.harmony.bundles.rest.platform.android.updater;

import java.io.File;

import com.tactfactory.harmony.meta.ClassMetadata;
import com.tactfactory.harmony.meta.EntityMetadata;
import com.tactfactory.harmony.platform.android.AndroidAdapter;
import com.tactfactory.harmony.updater.IExecutor;
import com.tactfactory.harmony.utils.ConsoleUtils;
import com.tactfactory.harmony.utils.TactFileUtils;

public class AddImplementsRestAndroid implements IExecutor {

    private final AndroidAdapter adapter;
    private final EntityMetadata entity;

    public AddImplementsRestAndroid(
            AndroidAdapter adapter, EntityMetadata entity) {
        this.adapter = adapter;
        this.entity = entity;
    }

    @Override
    public void execute() {
        this.addImplements();
    }

    /**
     * Add inheritance to java Entity and complete parcelable methods.
     * @param cm The entity metadata
     */
    private void addImplements() {
        boolean addImplements = false;
        final String entityName = this.entity.getName();
        final File entityFile =
                new File(this.adapter.getSourcePath()
                        + this.adapter.getApplicationMetadata().getProjectNameSpace()
                        + "/entity/" + entityName + ".java");
        final StringBuffer sb = TactFileUtils.fileToStringBuffer(entityFile);
        final String extendsString = " implements Resource";
        final String extendsNewImplements = ", Resource";
        final String classDeclaration = "class " + entityName;
        final String classExtends = " extends " + this.entity.getInheritance().getName();
        final int aClassDefinitionIndex =
                this.indexOf(sb, classDeclaration + classExtends, false)
                + classDeclaration.length();

        if (this.entity.getImplementTypes() != null
                && this.entity.getImplementTypes().size() > 0) {
            // Entity already extends something
            for (final String implementedClass : this.entity.getImplementTypes()) {
                // Extended class is not Entity Base
                if (!implementedClass.equals("Resource")) {
                        addImplements = false;
                        break;
                        //FileUtils.stringBufferToFile(sb, entityFile);
                    }
                }
        } else { // Entity doesn't extend anything
            sb.insert(aClassDefinitionIndex, extendsString);
        }

        if (addImplements) {
            sb.insert(aClassDefinitionIndex, extendsNewImplements);
        }

        // Add import EntityBase if it doesn't exist yet
        if (!this.entity.getImports().contains("Resource")) {
            final int packageIndex = this.indexOf(sb, "package", false);
            final int lineAfterPackageIndex =
                    sb.indexOf("\n", packageIndex) + 1;
            sb.insert(lineAfterPackageIndex,
                    String.format("%nimport %s.%s.base.Resource;%n",
                            this.adapter.getApplicationMetadata()
                                    .getProjectNameSpace().replace('/', '.'),
                            this.adapter.getModel()));
        }

        TactFileUtils.stringBufferToFile(sb, entityFile);
    }

    /**
     * Returns the first index of a content in a String buffer.
     * (can exclude comments)
     * @param sb The Strinbuffer to parse.
     * @param content The content to search for.
     * @param allowComments True to include comments in the search.
     * @return the index of the found String. -1 if nothing found.
     */
    private int indexOf(final StringBuffer sb,
            final String content,
            final boolean allowComments) {
        return this.indexOf(sb, content, 0, allowComments);
    }

    /**
     * Returns the first index of a content in a String buffer
     * after the given index.
     * (can exclude comments)
     * @param sb The Strinbuffer to parse.
     * @param content The content to search for.
     * @param fromIndex The index where to begin the search
     * @param allowComments True to include comments in the search.
     * @return the index of the found String. -1 if nothing found.
     */
    private int indexOf(final StringBuffer sb,
            final String content,
            final int fromIndex,
            final boolean allowComments) {
        int fIndex = fromIndex;
        int index = -1;
        if (allowComments) {
            index = sb.indexOf(content, fIndex);
        } else {
            int tmpIndex;
            do {
                tmpIndex = sb.indexOf(content, fIndex);
                final int lastCommentClose = sb.lastIndexOf("*/", tmpIndex);
                final int lastCommentOpen = sb.lastIndexOf("/*", tmpIndex);
                final int lastLineComment = sb.lastIndexOf("//", tmpIndex);
                final int lastCarriotRet = sb.lastIndexOf("\n", tmpIndex);
                // If the last multi-line comment is close
                // and if there is a carriot return
                // after the last single-line comment
                if (lastCommentClose >= lastCommentOpen
                    &&  lastLineComment  <= lastCarriotRet) {
                    // Index is good
                    index = tmpIndex;
                    break;
                } else {
                    fIndex = tmpIndex + 1;
                }
             } while (tmpIndex != -1);
        }

        return index;
    }

}
