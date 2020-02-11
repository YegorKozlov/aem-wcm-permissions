package com.adobe.gui.components.authoring.it.author.permissions.sites;

import com.adobe.gui.components.authoring.it.author.State;
import com.google.common.collect.ImmutableMap;
import org.apache.sling.testing.clients.ClientException;
import org.junit.Before;
import org.junit.Test;

import static com.adobe.gui.components.authoring.it.author.TestData.*;

public class SpanishContributorAccessIT extends AemSitesAccessTestCase {

    @Before
    public void setUp() {
        super.setUp();

        impersonate(ES_USER);
    }

    @Test
    public void testGlobalSiteEsAccess() throws ClientException {
        assertButtons(LANG_ES_PAGE, ImmutableMap.of(
                Copy, State.Hidden,
                Hello, State.Hidden,
                Hola, State.Visible,
                Translate, State.Hidden
                )
        );
    }

    @Test
    public void testGlobalSiteEnAccess() throws ClientException {
        assertButtons(LANG_EN_PAGE, ImmutableMap.of(
                Copy, State.Hidden,
                Hello, State.Hidden,
                Hola, State.Hidden,
                Translate, State.Hidden
                )
        );
    }
}
