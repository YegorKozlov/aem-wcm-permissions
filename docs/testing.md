# Integration Tests

The project demonstrates an approach how to validate permission-dependent components in AEM Touch UI using 
[sling.testing.clients](https://github.com/apache/sling-org-apache-sling-testing-clients).
The idea is that  attributes of the \<meta> tag in the page html depend on user privileges. 
The code can programmatically impersonate a user and assert the state of the buttons from this user'seye view.  

## Test Flow
1. Impersonate a user, e.g. a Spanish Contributor (jperez)
2. Navigate to a path in Sites Admin, e.g. [http://localhost:4502/sites.html/content/lang/en](http://localhost:4502/sites.html/content/lang/en).
3. Parse the html, select metadata for the given the given child path (/content/lang/en/hello-world) and
validate the action relations.

## Test Assumptions
The metadata of a collection item can be selected using the following selector
```
.foundation-collection-item[data-foundation-collection-item-id="${path}"]  meta.foundation-collection-quickactions
```
for example, the html on [http://localhost:4502/sites.html/content/lang/en](http://localhost:4502/sites.html/content/lang/en)
 would contain the following structure for the child page _/content/lang/en/hello-world_ in the 'column' view:
```html
<coral-columnview-item  class="foundation-collection-item" 
  data-foundation-collection-item-id="/content/lang/en/hello-world">
  ..
    <meta class="foundation-collection-quickactions" 
    data-foundation-collection-quickactions-rel="cq-siteadmin-admin-actions-lang-es-activator ... ">
 ...
</coral-columnview-item>
```

Given a user with known privileges the code can assert the action relations. For example, Spanish Contributors
have the lang:es privilege and should see the Hola button which means the _cq-siteadmin-admin-actions-lang-es-activator_ should be present.

## Assertion Matrix

### Spanish Contributors. See [SpanishContributorAccessIT](../it.tests/src/test/java/com/adobe/gui/components/authoring/it/author/permissions/sites/SpanishContributorAccessIT.java)

| Button  | granite:rel activator |  Present in \<meta> |
| :------------------- | :------------------- |:---------------|
| Hola | cq-siteadmin-admin-actions-lang-es-activator | Yes |
| Hello | cq-siteadmin-admin-actions-lang-en-activator | No |
| Translate | cq-siteadmin-admin-actions-lang-all-activator | No |
| Copy | cq-siteadmin-admin-actions-copy-activator | No |

### English Contributors. See [EnglishContributorAccessIT](../it.tests/src/test/java/com/adobe/gui/components/authoring/it/author/permissions/sites/EnglishContributorAccessIT.java)
| Button  | granite:rel activator |  Present in \<meta> |
| :------------------- | :------------------- |:---------------|
| Hola | cq-siteadmin-admin-actions-lang-es-activator | Yes |
| Hello | cq-siteadmin-admin-actions-lang-en-activator | No |
| Translate | cq-siteadmin-admin-actions-lang-all-activator | No |
| Copy | cq-siteadmin-admin-actions-copy-activator | No |

### Multilingvo Contributors. See [MultilingualContributorAccessIT](../it.tests/src/test/java/com/adobe/gui/components/authoring/it/author/permissions/sites/MultilingualContributorAccessIT.java)
| Button  | granite:rel activator |  Present in \<meta> |
| :------------------- | :------------------- |:---------------|
| Hola | cq-siteadmin-admin-actions-lang-es-activator | Yes |
| Hello | cq-siteadmin-admin-actions-lang-en-activator | No |
| Translate | cq-siteadmin-admin-actions-lang-all-activator | No |
| Copy | cq-siteadmin-admin-actions-copy-activator | No |

