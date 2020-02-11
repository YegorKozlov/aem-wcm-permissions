<%!
/*
* Base API to emit user actions in the metadata of items in the Site Admin (/sites.html)
*
* Every item in the collection, regardless of the view (column, card or list) has a <meta> element containing
* classes that activate the corresponding toolbar buttons when user selects the item, e.g. the Delete toolbar
* having the 'granite:rel=cq-siteadmin-admin-actions-delete-activator' property in the definition is shown only when the selected item
* has the 'cq-siteadmin-admin-actions-delete-activator' attribute in the metadata.
*
* This JSP should not evaluate or perform any execution task, rather it should only contain methods & configs to avoid performance overhead.
*
*/

/*
* @resource the resource being rendered. Can be a cq:Page or a folder .
* @page the page being rendered. Not <code>null</code> only only if @resource can be adapted to cq:Page
* @acm access control manager of the user's resource resolver
* @return list of activator classes, e.g. [cq-siteadmin-admin-actions-edit-activator,
*   cq-siteadmin-admin-actions-properties-activator, cq-siteadmin-admin-actions-lockpage-activator,
*   cq-siteadmin-admin-actions-copy-activator, cq-siteadmin-admin-actions-move-activator]
*/
private List<String> getActionRels(Resource resource, Page page, AccessControlManager acm, boolean hasAnalytics) {
    List<String> actionRels = new ArrayList<String>();

    if (page != null) {
        actionRels.add("cq-siteadmin-admin-actions-edit-activator");
        actionRels.add("cq-siteadmin-admin-actions-properties-activator");
    } else {
        // for nt:folder there are no properties to edit
        if (!resource.isResourceType("nt:folder")) {
            actionRels.add("cq-siteadmin-admin-actions-folderproperties-activator");
        }
    }

    if (hasAnalytics) {
        actionRels.add("cq-siteadmin-admin-actions-open-content-insight-activator");
    }

    if (page != null && hasPermission(acm, resource, Privilege.JCR_LOCK_MANAGEMENT)) {
        if (!page.isLocked()) {
            actionRels.add("cq-siteadmin-admin-actions-lockpage-activator");
        } else if (page.canUnlock()) {
            actionRels.add("cq-siteadmin-admin-actions-unlockpage-activator");
        }
    }

    if (hasPermission(acm, resource, "lang:es")) {
	    actionRels.add("cq-siteadmin-admin-actions-lang-es-activator");
    }
    if (hasPermission(acm, resource, "lang:en")) {
	    actionRels.add("cq-siteadmin-admin-actions-lang-en-activator");
    }
    if (hasPermission(acm, resource, "lang:all")) {
	    actionRels.add("cq-siteadmin-admin-actions-lang-all-activator");
    }
    if (hasPermission(acm, resource, "cq:copyPaste")) {
	    actionRels.add("cq-siteadmin-admin-actions-copy-activator");
    }

    boolean canDeleteLockedPage = (page != null && page.isLocked() && page.canUnlock()) || (page != null && !page.isLocked()) || page == null;

    if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE) && canDeleteLockedPage) {
        actionRels.add("cq-siteadmin-admin-actions-move-activator");
        actionRels.add("cq-siteadmin-admin-actions-delete-activator");
    }

    boolean canReplicate = hasPermission(acm, resource, "crx:replicate");
    if (canReplicate) {
        actionRels.add("cq-siteadmin-admin-actions-quickpublish-activator");
    }
    if (hasPermission(acm, "/etc/workflow/models", Privilege.JCR_READ)) {
        actionRels.add("cq-siteadmin-admin-actions-publish-activator");
    }

    boolean showCreate = false;

    if (page != null && (!page.isLocked() || page.canUnlock())) {
        actionRels.add("cq-siteadmin-admin-createworkflow");
        actionRels.add("cq-siteadmin-admin-createversion");
        showCreate = true;
    }

    if (hasPermission(acm, resource, Privilege.JCR_ADD_CHILD_NODES)) {
        actionRels.add("cq-siteadmin-admin-createlivecopy");
        showCreate = true;
    }

    if (!resource.getPath().equals("/content") && hasPermission(acm, "/content/launches", Privilege.JCR_ADD_CHILD_NODES)) {
        actionRels.add("cq-siteadmin-admin-createlaunch");
        showCreate = true;
    }

    if (showCreate) {
        actionRels.add("cq-siteadmin-admin-actions-create-activator");
        actionRels.add("cq-siteadmin-admin-createlanguagecopy");
    }
    if (page!=null){
        ValueMap pageProperties = page.getProperties();
        if (pageProperties !=null && pageProperties.containsKey("cq:lastTranslationDone")){
            //this is translation page 
            actionRels.add("cq-siteadmin-admin-actions-translation-update-memory");
        }
    }
    return actionRels;
}

private boolean hasPermission(AccessControlManager acm, String path, String privilege) {
    if (acm != null) {
        try {
            Privilege p = acm.privilegeFromName(privilege);
            return acm.hasPrivileges(path, new Privilege[]{p});
        } catch (RepositoryException ignore) {
        }
    }
    return false;
}

private boolean hasPermission(AccessControlManager acm, Resource resource, String privilege) {
    return hasPermission(acm, resource.getPath(), privilege);
}
%>