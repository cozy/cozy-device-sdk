Filtered Replication/Changes
============================

The pouchdb documentation is really good to understand it:

 * [API for filtered replication][1]
 * [API for filtered changes][2]
 * [Blog post for filtered replication][3]

The goal is to filter couch docs on the remote cozy, not on local device, to
avoid wasting bandwith to transfer useless docs and increase security.


Configuration
-------------

The configuration allow you to choose what you want to synchronize:

```javascript
config = {
    file: true,
    contact: true,
    calendar: true,
    notification: true,
}
```


Create a design doc with filters
--------------------------------

To create a filteredReplication, you must have:

 * a cozy URL: `https://demo.cozycloud.cc`
 * a device name, it's the login for authentication: `demo-laptop`
 * a password for authentication: `********`
 * a configuration
 * a callback

```javascript
config = { file: true }
cozyUrl = 'https://demo.cozycloud.cc'
deviceName = 'demo-laptop'
devicePassword = '********'
filteredReplication.setDesignDoc(cozyUrl, deviceName, devicePassword, config, callback)
```

Commands
--------

 * To get the filter name: `filteredReplication.getFilterName(deviceName)`
 * To get the id of the design doc: `filteredReplication.getDesignDocId(deviceName)`
 * To get the filtered function: `filteredReplication.getFilteredFunction(config)`
 * To generate the design doc: `filteredReplication.generateDesignDoc(deviceName, config)`
 * To get the design doc: `filteredReplication.getDesignDoc(cozyUrl, deviceName, devicePassword, callback)`
 * To remove the design doc: `filteredReplication.removeDesignDoc(cozyUrl, deviceName, devicePassword, callback)`


[1]:  https://pouchdb.com/api.html#filtered-replication
[2]:  https://pouchdb.com/api.html#filtered-changes
[3]:  https://pouchdb.com/2015/04/05/filtered-replication.html
