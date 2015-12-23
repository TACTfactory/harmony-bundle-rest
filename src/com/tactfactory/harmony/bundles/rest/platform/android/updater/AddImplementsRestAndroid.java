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
        if (this.entity.isResource()) {
            this.addExtendResource();
        }
    }

    /**
     * Add inheritance to java Entity and complete parcelable methods.
     * @param cm The entity metadata
     */
    private void addExtendResource() {
        boolean replaceImplement = false;
        boolean addImplement = true;

        final String entityName = this.entity.getName();
        final File entityFile =
                new File(this.adapter.getSourcePath()
                        + this.adapter.getApplicationMetadata().getProjectNameSpace()
                        + "/entity/" + entityName + ".java");
        final StringBuffer sb = TactFileUtils.fileToStringBuffer(entityFile);
        final String extendsString;
        final int indexEntityBase = this.indexOf(sb, "extends", false);
        final String classDeclaration = "class " + entityName;
        String classExtends;

        if (this.entity.getInheritance().getName() != null || indexEntityBase > -1) {
            classExtends = " extends EntityBase";
        } else {
            classExtends = "";
        }

        final int aClassDefinitionIndex =
                this.indexOf(sb, classDeclaration + classExtends, false)
                + classDeclaration.length();

        if (indexEntityBase == -1) {
            sb.insert(aClassDefinitionIndex, " extends EntityResourceBase");
        } else {
            sb.replace(aClassDefinitionIndex, aClassDefinitionIndex + "EntityBase".length(), " EntityResourceBase");
        }
//
        // Add import EntityBase if it doesn't exist yet
        if (!this.entity.getImports().contains("EntityResourceBase")) {
            final int packageIndex = this.indexOf(sb, "package", false);
            final int lineAfterPackageIndex =
                    sb.indexOf("\n", packageIndex) + 1;
            sb.insert(lineAfterPackageIndex,
                    String.format("%nimport %s.%s.base.EntityResourceBase;%n",
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
