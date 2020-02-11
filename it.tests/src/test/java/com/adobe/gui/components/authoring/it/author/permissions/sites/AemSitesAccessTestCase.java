package com.adobe.gui.components.authoring.it.author.permissions.sites;

import com.adobe.gui.components.authoring.it.author.Button;
import com.adobe.gui.components.authoring.it.author.permissions.BaseCollectionTestCase;

import static junit.framework.TestCase.assertNull;
import static junit.framework.TestCase.assertTrue;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;

/**
 * Base class for asserting state of the 'Site Admin' page
 */
public abstract class AemSitesAccessTestCase extends BaseCollectionTestCase {

    protected String getUrl() {
        return "/sites.html";
    }

    protected String getTitle() {
        return "AEM Sites";
    }

    public static final Button Copy = new Button("Copy", "cq-siteadmin-admin-actions-copy-activator");
    public static final Button Hola = new Button("Hola", "cq-siteadmin-admin-actions-lang-es-activator");
    public static final Button Hello = new Button("Hello", "cq-siteadmin-admin-actions-lang-en-activator");
    public static final Button Translate = new Button("Translate", "cq-siteadmin-admin-actions-lang-all-activator");

}
