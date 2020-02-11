package com.adobe.gui.components.authoring.it.author.permissions;

import org.apache.http.impl.cookie.BasicClientCookie;
import org.apache.sling.testing.clients.ClientException;
import org.apache.sling.testing.clients.SlingClient;
import org.apache.sling.testing.junit.rules.SlingInstanceRule;
import org.junit.After;
import org.junit.Before;
import org.junit.ClassRule;

import java.util.Date;

public class BaseAccessTestCase {
    private static String SUDO_COOKIE = "sling.sudo";
    public static final String CLEAR_IMPERSONATION = "-"; // clear impersonation

    @ClassRule
    public static SlingInstanceRule instanceRule = new SlingInstanceRule();

    protected SlingClient sling;

    @Before
    public void setUp() {
        sling = instanceRule.getAdminClient();
    }

    @After
    public void tearDown() {
        impersonate(CLEAR_IMPERSONATION);
    }

    public void impersonate(String userId)  {
        BasicClientCookie c = new BasicClientCookie(SUDO_COOKIE, "\"" + userId + "\"");
        c.setDomain(sling.getUrl().getHost());
        if(CLEAR_IMPERSONATION.equals(userId)){
            c.setExpiryDate(new Date(0));
        }
        sling.getCookieStore().addCookie(c);
    }

    /**
     * UserId of the current user.
     */
    public String getUser() {
        return sling.getCookieStore().getCookies().stream()
                .filter(cookie -> cookie.getName().equals(SUDO_COOKIE))
                .findFirst().map(c -> c.getValue().replace("\"", ""))
                .orElse(sling.getUser());

    }
}
