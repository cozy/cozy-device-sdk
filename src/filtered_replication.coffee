request = require 'superagent'
log     = require('printit')
    prefix: 'filteredReplication'


module.exports =


    getFilterName: (deviceName) ->
        log.debug "getFilterName #{deviceName}"

        "filter-#{deviceName}-config"


    getDesignDocId: (deviceName) ->
        log.debug "getDesignDocId #{deviceName}"

        "_design/#{@getFilterName deviceName}"


    getFilteredFunction: (config) ->
        log.debug "getFilteredFunction"

        throw new Error 'No config' unless config?

        filters = []

        if config.contact?
            filters.push "doc.docType.toLowerCase() === 'contact'"

        if config.calendar?
            filters.push "doc.docType.toLowerCase() === 'event'"
            filters.push "doc.docType.toLowerCase() === 'tag'"

        if config.file?
            filters.push "doc.docType.toLowerCase() === 'file'"
            filters.push "doc.docType.toLowerCase() === 'folder'"

        if config.notification?
            filters.push """
            (doc.docType.toLowerCase() === 'notification'
                && doc.type === 'temporary')
            """

        "function (doc) { return doc.docType && (#{filters.join ' || '}); }"


    generateDesignDoc: (deviceName, config) ->
        log.debug "generateDesignDoc #{deviceName}"

        # create couch doc
        _id: @getDesignDocId deviceName
        views: {} # fix couchdb error when views is not here
        filters:
            "#{@getFilterName deviceName}": @getFilteredFunction config


    setDesignDoc: (cozyUrl, deviceName, devicePassword, config, callback) ->
        log.debug "setDesignDoc #{cozyUrl}, #{deviceName}"

        unless config.file or config.contact or config.calendar \
                or config.notification
            return callback new Error "What do you want to synchronize?"

        client = request
            .put "#{cozyUrl}/ds-api/filters/config"
            .auth deviceName, devicePassword
            .send @generateDesignDoc deviceName, config
        client.end (err, res) ->
            if err
                callback err
            else if not res?.statusCode in [200, 201]
                message = res.body.error or
                    "invalid statusCode #{res?.statusCode}"
                callback new Error(message)
            else
                callback null, res.body


    getDesignDoc: (cozyUrl, deviceName, devicePassword, callback) ->
        log.debug "getDesignDoc #{cozyUrl}, #{deviceName}"

        client = request
            .get "#{cozyUrl}/ds-api/filters/config"
            .auth deviceName, devicePassword
        client.end (err, res) ->
            if err
                callback err
            else if res?.statusCode isnt 200
                message = res.body.error or
                    "invalid statusCode #{res?.statusCode}"
                callback new Error(message)
            else
                callback null, res.body


    removeDesignDoc: (cozyUrl, deviceName, devicePassword, callback) ->
        log.debug "removeDesignDoc #{cozyUrl}, #{deviceName}"

        client = request
            .del "#{cozyUrl}/ds-api/filters/config"
            .auth deviceName, devicePassword
        client.end (err, res) ->
            if err
                callback err
            else if not res?.statusCode in [200, 204]
                message = res.body.error or
                    "invalid statusCode #{res?.statusCode}"
                callback new Error(message)
            else
                callback null, res.body
