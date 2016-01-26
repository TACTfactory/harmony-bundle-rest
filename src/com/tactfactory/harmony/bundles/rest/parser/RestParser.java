/**
 * This file is part of the Harmony package.
 *
 * (c) Mickael Gaillard <mickael.gaillard@tactfactory.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package com.tactfactory.harmony.bundles.rest.parser;

import japa.parser.ast.ImportDeclaration;
import japa.parser.ast.body.ClassOrInterfaceDeclaration;
import japa.parser.ast.body.FieldDeclaration;
import japa.parser.ast.body.MethodDeclaration;
import japa.parser.ast.expr.AnnotationExpr;
import japa.parser.ast.expr.MemberValuePair;
import japa.parser.ast.expr.NormalAnnotationExpr;
import japa.parser.ast.expr.StringLiteralExpr;

import java.util.List;

import com.tactfactory.harmony.bundles.rest.annotation.Rest;
import com.tactfactory.harmony.bundles.rest.annotation.RestField;
import com.tactfactory.harmony.bundles.rest.meta.RestFieldMetadata;
import com.tactfactory.harmony.bundles.rest.meta.RestMetadata;
import com.tactfactory.harmony.meta.ApplicationMetadata;
import com.tactfactory.harmony.meta.ClassMetadata;
import com.tactfactory.harmony.meta.FieldMetadata;
import com.tactfactory.harmony.parser.BaseParser;
import com.tactfactory.harmony.utils.PackageUtils;

/**
 * Parser for Rest bundle.
 */
public class RestParser extends BaseParser {
    /** Bundle name. */
    private static final String REST = "rest";
    /** Rest annotation name. */
    private static final String ANNOT_REST =
            PackageUtils.extractNameEntity(Rest.class);
    /** Rest annotation name. */
    private static final String ANNOT_REST_FIELD =
            PackageUtils.extractNameEntity(RestField.class);
    /** Security argument name. */
    private static final String ANNOT_REST_SECURITY = "security";
    /** URI argument name. */
    private static final String ANNOT_REST_URI = "uri";
    /** DateFormat argument name. */
    private static final String ANNOT_REST_DATE_FORMAT = "dateFormat";
    /** DateFormat argument name. */
    private static final String ANNOT_REST_FIELD_NAME = "name";

    @Override
    public void visitClass(final ClassOrInterfaceDeclaration field,
            final ClassMetadata meta) {
        // TODO Auto-generated method stub

    }

    @Override
    public void visitField(final FieldDeclaration field,
            final ClassMetadata meta) {
        // TODO Auto-generated method stub

    }

    @Override
    public void visitMethod(final MethodDeclaration method,
            final ClassMetadata meta) {
        // TODO Auto-generated method stub

    }

    @Override
    public void visitImport(final ImportDeclaration imp,
            final ClassMetadata meta) {
        // TODO Auto-generated method stub

    }

    @Override
    public final void visitClassAnnotation(final ClassMetadata cm,
            final AnnotationExpr fieldAnnot) {
        if (fieldAnnot.getName().toString().equals(ANNOT_REST)) {
            final RestMetadata rm = new RestMetadata();
            rm.setEnabled(true);
            if (fieldAnnot instanceof NormalAnnotationExpr) {
                final NormalAnnotationExpr norm =
                        (NormalAnnotationExpr) fieldAnnot;
                final List<MemberValuePair> pairs = norm.getPairs();
                if (pairs != null) {
                    for (final MemberValuePair pair : pairs) {
                        if (pair.getName().equals(ANNOT_REST_SECURITY)) {
                            //TODO : Generate warning if type not recognized
                            String security = "";

                            if (pair.getValue() instanceof StringLiteralExpr) {
                                security = ((StringLiteralExpr)
                                        pair.getValue()).getValue();
                            } else {
                                security = pair.getValue().toString();
                            }

                            rm.setSecurity(Rest.Security.fromName(security));
                        } else

                            if (pair.getName().equals(ANNOT_REST_URI)) {
                                if (pair.getValue() instanceof StringLiteralExpr) {
                                    rm.setUri(((StringLiteralExpr)
                                            pair.getValue()).getValue());
                                } else {
                                    rm.setUri(pair.getValue().toString());
                                }
                            } else

                                if (pair.getName().equals(ANNOT_REST_DATE_FORMAT)) {
                                    if (pair.getValue() instanceof StringLiteralExpr) {
                                        rm.setDateFormat(((StringLiteralExpr)
                                                pair.getValue()).getValue());
                                    } else {
                                        rm.setDateFormat(
                                                pair.getValue().toString());
                                    }
                                }
                    }
                }
            }
            cm.getOptions().put(REST, rm);
        }

    }

    @Override
    public void visitFieldAnnotation(final FieldMetadata field,
            final AnnotationExpr fieldAnnot, final ClassMetadata meta) {
        if (fieldAnnot.getName().toString().equals(ANNOT_REST_FIELD)) {
            final RestFieldMetadata rm = new RestFieldMetadata(meta);

            if (fieldAnnot instanceof NormalAnnotationExpr) {
                final NormalAnnotationExpr norm =
                        (NormalAnnotationExpr) fieldAnnot;
                final List<MemberValuePair> pairs = norm.getPairs();

                if (pairs != null) {

                    for (final MemberValuePair pair : pairs) {

                        if (pair.getName().equals(ANNOT_REST_FIELD_NAME)) {
                            String name = "";

                            if (pair.getValue() instanceof StringLiteralExpr) {
                                name = ((StringLiteralExpr)
                                        pair.getValue()).getValue();
                            } else {
                                name = pair.getValue().toString();
                            }

                            rm.setRestName(name);
                        }
                    }
                }
            }

            field.getOptions().put(REST, rm);
        }
    }

    @Override
    public void callFinalCompletor() {
        new RestCompletor().generateApplicationRestMetadata(
                ApplicationMetadata.INSTANCE);
    }
}
