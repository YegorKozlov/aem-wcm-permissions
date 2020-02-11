<%@include file="/libs/granite/ui/global.jsp"%><%
%><%@page session="false"%><%
%><%@page import="com.adobe.cq.contentinsight.ProviderSettingsManager,
                  com.adobe.granite.security.user.util.AuthorizableUtil,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Tag,
                  com.day.cq.wcm.api.Page,
                  com.day.cq.wcm.api.Template,
                  com.day.cq.wcm.msm.api.LiveRelationshipManager,
                  com.day.cq.dam.api.Asset,
                  com.day.cq.commons.jcr.JcrConstants,
                  org.apache.commons.lang.StringUtils,
                  org.apache.jackrabbit.util.Text,
                  org.apache.sling.api.resource.ValueMap,
                  javax.jcr.RepositoryException,
                  javax.jcr.Session,
                  javax.jcr.security.AccessControlManager,
                  javax.jcr.security.Privilege,
                  java.util.ArrayList,
                  java.util.Calendar,
                  java.util.Iterator,
                  java.util.List" 
%><%@include file="/apps/cq/gui/components/coral/admin/page/common/permissions.jsp"%><%

AccessControlManager acm = null;
try {
    acm = resourceResolver.adaptTo(Session.class).getAccessControlManager();
} catch (RepositoryException e) {
    log.warn("Unable to get access manager", e);
}

ProviderSettingsManager providerSettingsManager = sling.getService(ProviderSettingsManager.class);
boolean hasAnalytics = false;
if (providerSettingsManager != null) {
    hasAnalytics = providerSettingsManager.hasActiveProviders(resource);
}

Page cqPage = resource.adaptTo(Page.class);
String title = "";
String name = null;
String actionRels = StringUtils.join(getActionRels(resource, cqPage, acm, hasAnalytics), " ");

if (cqPage != null) {
    String cqPageTitle = cqPage.getTitle();
    if (StringUtils.isEmpty(cqPageTitle)) {
        // Fallback to name for the title
        title = cqPage.getName();
    }
    else {
        // Get both name and title if title exists
        title = cqPageTitle;
        name = cqPage.getName();
    }
}
else {
    ValueMap vm = resource.getValueMap();
    title = vm.get(JcrConstants.JCR_CONTENT + "/" + JcrConstants.JCR_TITLE, vm.get(JcrConstants.JCR_TITLE, String.class));
    if (StringUtils.isEmpty(title)) {
        // Fallback to name for the title
        title = resource.getName();
    }
    else {
        // Get both name and title if title exists
        name = resource.getName();
    }
}

LiveRelationshipManager liveRelationshipManager = resourceResolver.adaptTo(LiveRelationshipManager.class);
boolean isLiveCopy = liveRelationshipManager.hasLiveRelationship(resource);


Tag tag = cmp.consumeTag();
AttrBuilder attrs = tag.getAttrs();

attrs.add("itemscope", "itemscope");
attrs.add("data-timeline", true);
attrs.add("data-cq-page-livecopy", isLiveCopy);
attrs.add("data-foundation-picker-collection-item-text", resource.getPath());

if (hasChildren(resource)) {
    attrs.add("variant", "drilldown");
}

%><coral-columnview-item <%= attrs %>>
    <coral-columnview-item-thumbnail><%
        String thumbnailUrl = null;

        if (cqPage != null) {
            thumbnailUrl = getThumbnailUrl(cqPage, 48, 48);
        } else {
            Asset asset = resource.adaptTo(Asset.class);

            if (asset != null) {
                String assetTitle = asset.getMetadataValue("dc:title");

                if (assetTitle != null) {
                    name = title;
                    title = assetTitle;
                }

                thumbnailUrl = getThumbnailUrl(resource, 48, 48);
            }
        }

        if (thumbnailUrl != null) {
            %><img class="foundation-collection-item-thumbnail" src="<%= xssAPI.getValidHref(request.getContextPath() + thumbnailUrl) %>" alt="" itemprop="thumbnail"><%
        } else {
            %><coral-icon class="foundation-collection-item-thumbnail" icon="folder"></coral-icon><%
        }
    %></coral-columnview-item-thumbnail>
    <coral-columnview-item-content>
        <div class="foundation-collection-item-title" itemprop="title" title="<%= xssAPI.encodeForHTMLAttr(title) %>">
            <%= xssAPI.encodeForHTML(title) %>
        </div><%
        if (name != null && !name.equals(title)) {
            %><div class="foundation-layout-util-subtletext">
                <%= xssAPI.encodeForHTML(name) %>
            </div><%
        }%>
    </coral-columnview-item-content>

    <meta class="foundation-collection-quickactions" 1 data-foundation-collection-quickactions-rel="<%= xssAPI.encodeForHTMLAttr(actionRels) %>">
    <link rel="admin" href="<%= xssAPI.getValidHref(request.getContextPath() + "/sites.html" + Text.escapePath(resource.getPath()))%>"><%

    if (cqPage != null && cqPage.getLastModified() != null) {
        %><meta itemprop="lastmodified" content="<%= cqPage.getLastModified().getTimeInMillis() %>">
        <meta itemprop="lastmodifiedby" content="<%= xssAPI.encodeForHTML(AuthorizableUtil.getFormattedName(resourceResolver, cqPage.getLastModifiedBy())) %>"><%
    }
%></coral-columnview-item><%!

    private String getThumbnailUrl(Page page, int width, int height) {
        String ck = "";

        ValueMap metadata = page.getProperties("image/file/jcr:content");
        if (metadata != null) {
            Calendar cal = metadata.get("jcr:lastModified", Calendar.class);
            if (cal != null) {
                ck = "" + (cal.getTimeInMillis() / 1000);
            }
        }

        return Text.escapePath(page.getPath()) + ".thumb." + width + "." + height + ".png?ck=" + ck;
    }

    private static String getThumbnailUrl(Resource r, int width, int height) {
        return Text.escapePath(r.getPath()) + ".thumb." + width + "." + height + ".png";
    }


    private boolean hasChildren(Resource resource) {
        for (Iterator<Resource> it = resource.listChildren(); it.hasNext(); ) {
            Resource r = it.next();

            // don't consider repository nodes (e.g. rep:policy) or content resources as children (Timewarp incorrectly
            // exposes jcr:frozenNode as the page's content resource, hence we need to test for it at the moment)
            if (r.getName().startsWith("rep:") || r.getName().equals(JcrConstants.JCR_CONTENT)
                    || r.getName().equals(JcrConstants.JCR_FROZENNODE)) {
                continue;
            }
            return true;
        }

        return false;
    }
%>
