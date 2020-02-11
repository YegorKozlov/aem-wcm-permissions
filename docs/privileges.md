# Custom Oak Privileges 

A privilege in a Oak repository represents the ability to perform a particular set of operations on a node. 
Each privilege is identified by a JCR name and registered in the repository as a _rep:Privilege_ node underneath _/jcr:system/rep:privileges_, e.g.
```
+ /jcr:system/rep:privileges
  + jcr:read
  + jcr:readAccessControl
  + rep:write
    ...
```

Packages can register custom JCR privileges during import by providing a META-INF/vault/privileges.xml file.

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<privileges
        xmlns:cq="http://www.day.com/jcr/cq/1.0"
        xmlns:lang="http://github.com/permissions/lang/1.0" 
>
   <privilege abstract="false" name="lang:es"/>
   <privilege abstract="false" name="lang:en"/>
   <privilege abstract="false" name="lang:all">
      <contains name="lang:es"/>
      <contains name="lang:en"/>
   </privilege> 
   <privilege abstract="false" name="cq:copyPaste"/>
</privileges>
```

The Package Manager will first ensure all the namespaces exist underneath _/jcr:system/rep:namespaces_ and then will register the privileges. 
The definition above will result in the following structure of nodes:

```
+ /jcr:system/rep:privileges
  ... 
  + lang:es
  + lang:en
  + lang:all
    - rep:aggregates [lang:es, lang:en]
  + cq:copyPaste
```

Once created, custom privileges are regular citizens of the repository. 
You can view and grant them in CRXDE, reference in rep:policy nodes in your content packages 
or reference in scripting tools like [AC Tool](https://github.com/Netcentric/accesscontroltool) by Netcentric

> [!NOTE]
> Registering namespaces and privileges in Jackrabbit Oak is a one-way operation. 
> The [PrivilegeManager API](https://jackrabbit.apache.org/oak/docs/security/privilege.html) 
> does not provide a "removePrivilege" operation, so privileges can only be registered, but not unregistered/cleaned up.
