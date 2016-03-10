Filter Manager
==============

Create a device filter in cozy couch


Constructor
-----------

To create a FilterManager you must have:

 * a cozy URL: `https://demo.cozycloud.cc`
 * an device name, it's the login for authentication': `demo-laptop`
 * a password for authentication: `********`

```javascript
cozyUrl = 'https://demo.cozycloud.cc'
deviceName = 'demo-laptop'
password = '********'
filterManager = new FilterManager(cozyUrl, deviceName, password);
```

Commands
--------

 * To create or update a filter you must have a configuration:
   `filterManager.createOrUpdate(config)`
 * To get filter name: `filterManager.getFilterName()`
 * To get doc id: `filterManager.getDocId()`


Configuration
-------------

The configuration allow you what you want synchronize:

```javascript
config = {
    file: true,
    folder: true,
    contact: true,
    calendar: true,
    notification: true,
}
```
