package com.adobe.gui.components.authoring.it.author.permissions;

import com.adobe.gui.components.authoring.it.author.Button;
import com.adobe.gui.components.authoring.it.author.State;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.message.BasicHeader;
import org.apache.sling.testing.clients.ClientException;
import org.apache.sling.testing.clients.SlingHttpResponse;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Selector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.lang.invoke.MethodHandles;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.BiFunction;

import static junit.framework.TestCase.assertFalse;
import static junit.framework.TestCase.assertTrue;
import static org.apache.http.HttpStatus.SC_OK;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public abstract class BaseCollectionTestCase extends BaseAccessTestCase {
    private final static Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

    enum View {
        column,
        card,
        list
    }

    protected abstract String getUrl();

    protected abstract String getTitle();

    protected View[] views() {
        return View.values();
    }

    /**
     * Navigate to a path in the SiteAdmin and return parsed html
     *
     * @param path the path to open, e.g./content/lang/en
     * @param view the view, e.g. card, list or column
     * @return parsed html response from http://localhost:4502/sites.html/content/lang/en
     */
    private Element navigate(String path, View view) throws ClientException {
        String url = getUrl() + path;
        logger.info("{}: {}", view, url);
        SlingHttpResponse response = sling.doGet(url, null,
                Collections.singletonList(new BasicHeader("Cookie", "cq-sites=" + view.name())), SC_OK);
        Document doc = Jsoup.parse(response.getContent());
        assertEquals(getTitle(), doc.title());
        return doc.body();
    }

    /**
     * Apply the <code>assertFunc</code> to the collection item
     *
     * @param body       html, e.g. http://localhost:4502/sites.html/content/lang/en
     * @param assertFunc function to apply to each the collection item
     */
    private void assertCollectionItem(Element body, String path, BiFunction<String, List<String>, Void> assertFunc) {
        String cssQuery = ".foundation-collection-item[data-foundation-collection-item-id=\""+path+"\"]";
        Element foundationItem = body.selectFirst(cssQuery);
        assertNotNull(cssQuery, foundationItem);
        Element meta = body.selectFirst("meta.foundation-collection-quickactions");

        logger.debug("asserting access to {}", path);
        String quickactions = meta.attr("data-foundation-collection-quickactions-rel");
        List<String> rels = Arrays.asList(quickactions.split("\\s+"));
        assertFunc.apply(path, rels);
    }

    /**
     * Assert that a button exists in the selection toolbar of a collection page.
     * The action toolbar is activated when user selects an item in a collection view, e.g.
     * selecting a page activates 'Edit', 'Move', 'Delete' , etc.
     *
     * @param body   parsed html of a collection page, e.g. content
     * @param button button to assert
     */
    private void assertToolbarButton(Element body, Button button) {
        String cssQuery = "coral-actionbar > coral-actionbar-primary";
        Element actionBar = body.selectFirst(cssQuery);
        assertNotNull("not found: " + cssQuery, actionBar);

        String rel = button.activator();
        String title = button.title();
        logger.debug(cssQuery + ": " + title);
        cssQuery = "coral-actionbar-item .foundation-collection-action";
        Element btn = Selector.select(cssQuery, actionBar).stream()
                .filter(e -> e.text().equals(title)).findFirst().orElse(null);
        assertNotNull("not found: " + cssQuery, btn);
        assertTrue(title + " does not have class " + rel, btn.hasClass(rel));
    }


    private void assertCollectionButtons(Element html, String path, Map<Button, State> buttons) {
        for (Button button : buttons.keySet()) {
            // assert the buttons exists in the page html
            assertToolbarButton(html, button);

            BiFunction<String, List<String>, Void> assertFunc = (href, rels) -> {
                String activator = button.activator();
                State state = buttons.get(button);
                switch (state) {
                    case Visible:
                        logger.debug("asserting {} present for {} for {}", activator, href, getUser());
                        assertTrue(activator + " should be present for " + href, rels.contains(activator));
                        break;
                    case Hidden:
                        logger.debug("asserting {} not present for {} for {}", activator, href, getUser());
                        assertFalse(activator + " should not be present for " + href, rels.contains(activator));
                        break;
                }
                return null;
            };
            // assert the action relations defined in the <meta> tag
            assertCollectionItem(html, path, assertFunc);
        }

    }

    private static String getParentPath(String path) {
        final String normalizedPath = StringUtils.removeEnd(path, "/");  // remove trailing slash in case of folders
        return StringUtils.substringBeforeLast(normalizedPath, "/");
    }

    public void assertButtons(String path, Map<Button, State> buttons) throws ClientException {
        String parentPath = getParentPath(path);

        for (View view : views()) {
            Element html = navigate(parentPath, view);
            assertCollectionButtons(html, path, buttons);
        }
    }

}
