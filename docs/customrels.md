# Customizing Buttons in Sites Admin

The project introduces four custom buttons in Sites Admin activated by custom privileges: 

### Custom Privileges
| Privileges | Description  |
| :------------------- | :-------------------  |
| lang:es | Access Spanish-specific actions (Hola button) |
| lang:en | Access English-specific actions (Hello button) |
| lang:all | Aggregate privilege including _lang:es_ and _lang:en_. Users having it can access both the Hola and Hello buttons|
| cq:copyPaste | Only show the Copy button if a user has the cq:copyPaste privilege. The use-case is to restrict copy-pasting and encourage authors to create new pages. |

See [permissions.xml](./pom.xml)

### Test Groups And Users
| Group  | Privileges on /content/lang | Test User  |
| :------------------- | :------------------- |:------------------- |
| Spanish Contributors  | lang:es | jperez  |
| English Contributors  | lang:en | jdow  |
| Multilingual Contributors  | lang:all,cq:copyPaste | bjean  |

### Buttons in Sites Admin

The code customizes the Copy button and adds three new buttons in [Sites Admin](http://localhost:4502/sites.html/content/lang) 

| Button  | Required Privilege |  Who can access | granite:rel activator |
| :------------------- | :------------------- |:---------------|:---------------|
| Copy  | cq:copyPaste | Bilingvo Contributors | cq-siteadmin-admin-actions-copy-activator |
| Hola  | lang:es | Spanish and Multilingual Contributors  | cq-siteadmin-admin-actions-lang-es-activator |
| Hello  | lang:en | English and Multilingual Contributors | cq-siteadmin-admin-actions-lang-en-activator |
| Translate  | lang:all | Multilingual Contributors | cq-siteadmin-admin-actions-lang-all-activator |

 
