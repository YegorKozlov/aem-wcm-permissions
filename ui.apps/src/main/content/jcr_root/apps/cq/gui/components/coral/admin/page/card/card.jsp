<%@include file="/libs/granite/ui/global.jsp"%><%
%><%@page session="false"%><%
%><%@page import="com.adobe.cq.contentinsight.ProviderSettingsManager,
                  com.adobe.cq.social.commons.CommentSystem,
                  com.adobe.cq.wcm.launches.utils.LaunchUtils,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Tag,
                  com.adobe.granite.workflow.exec.WorkItem,
                  com.adobe.granite.workflow.exec.Workflow,
                  com.adobe.granite.workflow.status.WorkflowStatus,
                  com.day.cq.i18n.I18n,
                  com.day.cq.replication.ReplicationStatus,
                  com.day.cq.wcm.api.Page,
                  com.day.cq.wcm.api.Template,
                  com.day.cq.wcm.msm.api.LiveRelationshipManager,
                  org.apache.commons.lang.StringUtils,
                  org.apache.jackrabbit.api.security.user.Authorizable,
                  org.apache.jackrabbit.api.security.user.Group,
                  org.apache.jackrabbit.api.security.user.User,
                  org.apache.jackrabbit.api.security.user.UserManager,
                  org.apache.jackrabbit.util.Text,
                  org.apache.sling.api.resource.ValueMap,
                  javax.jcr.RepositoryException,
                  javax.jcr.Session,
                  javax.jcr.security.AccessControlManager,
                  javax.jcr.security.Privilege,
                  java.util.ArrayList,
                  java.util.Calendar,
                  java.util.HashMap,
                  java.util.List,
                  java.util.Map" 
%><%@include file="/apps/cq/gui/components/coral/admin/page/common/permissions.jsp"%><%

LiveRelationshipManager liveRelationshipManager = resourceResolver.adaptTo(LiveRelationshipManager.class);
ReplicationStatus replicationStatus = resource.adaptTo(ReplicationStatus.class);
Authorizable currentUser = resourceResolver.adaptTo(Authorizable.class);
UserManager userManager = resource.adaptTo(UserManager.class);
WorkflowStatus workflowStatus = resource.adaptTo(WorkflowStatus.class);
List<WorkItem> workItems = getWorkItems(currentUser, workflowStatus, userManager);

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
String title;
String actionRels = StringUtils.join(getActionRels(resource, cqPage, acm, hasAnalytics), " ");

Tag tag = cmp.consumeTag();
AttrBuilder attrs = tag.getAttrs();

boolean isLaunchCopy = LaunchUtils.isLaunchResourcePath(resource.getPath());
boolean isLiveCopy = liveRelationshipManager.hasLiveRelationship(resource);
int commentCount = 0;
boolean isNew = false;
boolean isFolder = false;
String thumbnailUrl = "";

if (cqPage != null) {
    title = cqPage.getTitle();
    if (StringUtils.isEmpty(title)) {
        title = cqPage.getName();
    }
    commentCount = getCommentCount(cqPage);

    thumbnailUrl = getThumbnailUrl(cqPage, 800, 480);

    if (thumbnailUrl.startsWith("/")) {
        thumbnailUrl = request.getContextPath() + thumbnailUrl;
    }

    isNew = isNew(cqPage);
} else {
    ValueMap vm = resource.getValueMap();
    title = vm.get("jcr:content/jcr:title", vm.get("jcr:title", resource.getName()));
    isFolder = true;
    attrs.add("variant", "inverted");
}

Calendar publishedDate = null;
Boolean isDeactivated = false;

if (replicationStatus != null) {
    publishedDate = replicationStatus.getLastPublished();
    isDeactivated = replicationStatus.isDeactivated();
}

attrs.addClass("foundation-collection-navigator");

attrs.add("data-timeline", true);
attrs.add("data-cq-page-livecopy", isLiveCopy);

String href = null;
if (cqPage != null) {
    href = "/libs/wcm/core/content/sites/properties.html?item=" + Text.escape(cqPage.getPath());
} else if (!resource.isResourceType("nt:folder")) {
    // for nt:folder there are no properties to edit
    href = "/libs/wcm/core/content/sites/folderproperties.html" + Text.escapePath(resource.getPath());
}

%><coral-card <%= attrs %>><%
    if (cqPage != null) {
        %><coral-card-asset>
            <img src="<%= xssAPI.getValidHref(thumbnailUrl) %>">
        </coral-card-asset><%
        if (isNew || workItems.size() > 0) {
            %><coral-card-info><%
                if (isNew) {
                    %><coral-tag color="blue" class="u-coral-pullRight"><%= xssAPI.encodeForHTML(i18n.get("New")) %></coral-tag><%
                }

                if (workItems.size() > 0) {
                    Map<String, Integer> workflowCountByTitle = getWorkflowCountByTitle(workItems, i18n);

                    for (Map.Entry<String, Integer> entry : workflowCountByTitle.entrySet()) {
                        %><coral-alert variant="info" size="S">
                            <coral-alert-content>
                            <% if (entry.getValue() > 1) {
                                %><coral-tag class="u-coral-pullRight" size="M" color="blue"><%= xssAPI.encodeForHTML(Integer.toString(entry.getValue())) %></coral-tag><%
                            }%><%= xssAPI.encodeForHTML(entry.getKey()) %>
                            </coral-alert-content>
                        </coral-alert><%
                    }
                }
            %></coral-card-info><%
        }
    }

    %><coral-card-content><%
        String context = isLaunchCopy ? i18n.get("Launch Copy") : isLiveCopy ? i18n.get("Live Copy") : isFolder ? i18n.get("Folder") : null;
        if (context != null) {
            %><coral-card-context><%= xssAPI.encodeForHTML(context) %></coral-card-context><%
        }
        %><coral-card-title class="foundation-collection-item-title"><%= xssAPI.encodeForHTML(title) %></coral-card-title><%

        if (cqPage != null) {
            if (cqPage.isHideInNav() || cqPage.isLocked() || commentCount > 0) {
            %><coral-card-propertylist><%
                if (cqPage.isHideInNav()) {
            %><coral-card-property icon="viewOff" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Hidden in navigation")) %>"></coral-card-property><%
                }
                if (cqPage.isLocked()) {
            %><coral-card-property icon="lockOn" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Locked")) %>"></coral-card-property><%
                }
                if (commentCount > 0) {
            %><coral-card-property icon="comment" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Comments")) %>"><%= xssAPI.encodeForHTML(Integer.toString(commentCount)) %></coral-card-property><%
                }
            %></coral-card-propertylist><%
            }

            %><coral-card-propertylist><%
                if (cqPage.getLastModified() != null) {
            %><coral-card-property icon="edit" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Modified")) %>">
                <foundation-time value="<%= xssAPI.encodeForHTMLAttr(cqPage.getLastModified().toInstant().toString()) %>"></foundation-time>
</coral-card-property><%
                }

                if (!isDeactivated && publishedDate != null) {
            %><coral-card-property icon="globe" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Published")) %>"><foundation-time value="<%= xssAPI.encodeForHTMLAttr(publishedDate.toInstant().toString()) %>"></foundation-time></coral-card-property><%
                } else {
            %><coral-card-property icon="globeRemove"><%= xssAPI.encodeForHTML(i18n.get("Not published")) %></coral-card-property><%
                }
            %></coral-card-propertylist><%
        }
    %></coral-card-content>
    <meta class="foundation-collection-quickactions" data-foundation-collection-quickactions-rel="<%= xssAPI.encodeForHTMLAttr(actionRels) %>">
    <link rel="properties" href="<%= xssAPI.getValidHref(request.getContextPath() + href) %>"></link>
</coral-card>
<coral-quickactions target="_prev" alignmy="left top" alignat="left top">
    <coral-quickactions-item icon="check" class="foundation-collection-item-activator"><%= xssAPI.encodeForHTML(i18n.get("Select")) %></coral-quickactions-item><%

    if (cqPage != null && hasPermission(acm, resource, Privilege.JCR_READ)) {
        %><coral-quickactions-item icon="edit" class="foundation-collection-action" data-foundation-collection-action='{"action": "cq.wcm.open", "data": {"cookiePath":"<%= request.getContextPath() %>/","href":"<%= request.getContextPath() %>/bin/wcmcommand?cmd=open&_charset_=utf-8&path={item}"}}'
        ><%= xssAPI.encodeForHTML(i18n.get("Edit")) %></coral-quickactions-item><%
    }

    if (href != null) {
        %><coral-quickactions-item icon="infoCircle" type="anchor" href="<%= xssAPI.getValidHref(request.getContextPath() + href) %>"
            ><%= xssAPI.encodeForHTML(i18n.get("Properties")) %></coral-quickactions-item><%
    }

    if (hasPermission(acm, resource, "crx:replicate")) {
        %><coral-quickactions-item icon="globe" class="foundation-collection-action"
            data-foundation-collection-action='{"action": "cq.wcm.quickpublish", "data": {"referenceSrc": "<%=
            request.getContextPath() %>/libs/wcm/core/content/reference.json?_charset_=utf-8{&path*}"}}'
            ><%= xssAPI.encodeForHTML(i18n.get("Quick Publish")) %></coral-quickactions-item><%
    }

    %><coral-quickactions-item icon="copy" class="foundation-collection-action" data-foundation-collection-action='{"action": "cq.wcm.copy"}'
        ><%= xssAPI.encodeForHTML(i18n.get("Copy")) %></coral-quickactions-item><%

    if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
        String parentPath = resource.getParent().getPath();
        String moveHref = "/libs/wcm/core/content/sites/movepagewizard.html" + Text.escapePath(parentPath) + "?item=" + Text.escape(resource.getPath()) + "&_charset_=utf-8";

        %><coral-quickactions-item icon="move" type="anchor"
            href="<%= xssAPI.getValidHref(request.getContextPath() + moveHref) %>"><%= xssAPI.encodeForHTML(i18n.get("Move")) %></coral-quickactions-item><%
    }
%></coral-quickactions><%!
private boolean isNew(Page page) {
    Calendar created = page.getProperties().get("jcr:created", Calendar.class);
    Calendar lastModified = page.getLastModified();

    Calendar twentyFourHoursAgo = Calendar.getInstance();
    twentyFourHoursAgo.add(Calendar.DATE, -1);

    if (created == null || (lastModified != null && lastModified.before(created))) {
        created = lastModified;
    }

    return created != null && twentyFourHoursAgo.before(created);
}

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

private int getCommentCount(Page page) {
    Resource contentResource = page.getContentResource();

    if (contentResource != null) {
        Resource commentsResource = contentResource.getChild("alt/comments");

        if (commentsResource != null) {
            CommentSystem commentSystem = commentsResource.adaptTo(CommentSystem.class);

            if (commentSystem != null) {
                return commentSystem.countComments();
            }
        }
    }

    return 0;
}

private Map<String, Integer> getWorkflowCountByTitle(List<WorkItem> workItems, I18n i18n) {
    Map<String, Integer> workflowTitles = new HashMap<String, Integer>();

    for (WorkItem item : workItems) {
        String workflowTitle = i18n.getVar(item.getNode().getTitle());

        if(!workflowTitles.containsKey(workflowTitle)) {
            workflowTitles.put(workflowTitle, 1);
        }
        else {
            workflowTitles.put(workflowTitle, workflowTitles.get(workflowTitle) + 1);
        }
    }

    return workflowTitles;
}

private List<WorkItem> getWorkItems(Authorizable user, WorkflowStatus workflowStatus, UserManager userManager)
    throws RepositoryException {
    List<WorkItem> workItems = new ArrayList<WorkItem>();

    if (workflowStatus != null && workflowStatus.isInRunningWorkflow(true)) {
        List<Workflow> workflows = workflowStatus.getWorkflows(true);
        for (Workflow workflow : workflows) {
            for (WorkItem item : workflow.getWorkItems()) {
                boolean isAssigned = false;
                String assigneeId = item.getCurrentAssignee();
                Authorizable assignee = assigneeId != null ? userManager.getAuthorizable(assigneeId) : null;

                if (assignee != null) {
                    if (((User) user).isAdmin()) {
                        isAssigned = true;
                    } else if (assignee.isGroup()) {
                        Group group = (Group) assignee;
                        isAssigned = group.isMember(user);
                    } else {
                        isAssigned = assignee.getID().equals(user.getID());
                    }
                }
                if (isAssigned) {
                    workItems.add(item);
                }
            }
        }
    }

    return workItems;
}

%>
