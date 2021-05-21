# AEM  Permission-Dependent Buttons Demo

The project demonstrates how to add custom buttons in AEM Sites Admin and show/hide them
based on custom user privileges.

## Modules
The project consists of three modules
- ui.apps:  contains the /apps part of the project and a [script](ui.apps/src/main/content/META-INF/vault/privileges.xml)
 to install custom Oak privileges. See [Custom Oak Privileges](docs/privileges.md)
- ui.content: sample content, groups and users to demonstrate the work
- it.tests: http integration tests based on [sling.testing.clients](https://github.com/apache/sling-org-apache-sling-testing-clients).
The tests impersonate users with different privileges and assert html from their eye view. See [Integration Tests](docs/testing.md)

## How to view the demo

- Impersonate John Dow (jdow) who is a member of English Contributors and navigate to [AEM Sites](http://localhost:4502/sites.html/content/lang/en).
Select the Hello World page and see the Hello button in the selection toolbar. 
Then Navigate to [AEM Sites](http://localhost:4502/sites.html/content/lang/es) and select the Hola Mundo page. 
The Hello button is hidden because John Dow does not have lang:en privilege on this path.
- Impersonate Juan Perez (jperez) who is a member of Spanish Contributors, navigate to [AEM Sites](http://localhost:4502/sites.html/content/lang)
and see the Hola button in the seleciton toolbar. The Hello button is hidden because Juan Perez does not
have lang:en privilege.
- Impersonate Billy Jean (bjean) who is a member of Multilingvo Contributors. 
This user can access both Hello and Hola buttons.  Billy Jean can also access the Copy button which is activated by a special _cq:copyPage_ privilege.

See the [Assertion Matrix](docs/testing.md#markdown-header-assertion-matrix)

## How to build
To build all the modules run in the project root directory the following command with Maven 3:
```
mvn clean install
```
If you have a running AEM instance you can build and package the whole project and deploy into AEM with

```
mvn clean install -PautoInstallPackage,integrationTests
```
## Documentation
- [Oak Privileges](docs/privileges.md)
- [Approaches To Show / Hide Components Based On Permissions](docs/actionrels.md)
- [Customizing Buttons in Sites Admin](docs/customrels.md)
- [Integration Tests](docs/testing.md)


