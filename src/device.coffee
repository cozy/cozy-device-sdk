request = require 'request-json-light'
log     = require('printit')
    prefix: 'device'


# Some methods to discuss with a cozy stack
module.exports = Device =

    # Pings the URL to check if it is a Cozy
    pingCozy: (cozyUrl, callback) ->
        log.debug "pingCozy #{cozyUrl}"

        client = request.newClient cozyUrl
        client.get "status", (err, res, body) ->
            if res?.statusCode isnt 200
                callback new Error "No cozy at this URL"
            else
                callback()


    # Pings the cozy to check the credentials without creating a device
    checkCredentials: (cozyUrl, cozyPassword, callback) ->
        log.debug "checkCredentials #{cozyUrl}"

        client = request.newClient cozyUrl
        data =
            login: 'owner'
            password: cozyPassword

        client.post "login", data, (err, res, body) ->
            if res?.statusCode isnt 200
                err = err?.message or body.error or body.message
            callback err


    # Register device remotely then returns credentials given by remote Cozy.
    # This credentials will allow the device to access to the Cozy database.
    # Perms is optional. If given, it is used to indicate the permissions
    # of the device. The default permissions cover files, folders and binaries.
    registerDevice: (cozyUrl, deviceName, cozyPassword, perms, callback) ->
        log.debug "registerDevice #{cozyUrl}, #{deviceName}"

        client = request.newClient cozyUrl
        client.setBasicAuth 'owner', cozyPassword

        device = login: deviceName
        if callback?
            device.permissions = perms
        else
            callback = perms

        client.post 'device/', device, (err, res, body) ->
            if err
                callback err
            else if body.error?
                callback body.error
            else
                callback null,
                    id: body.id
                    deviceName: deviceName
                    password: body.password


    # Same as registerDevice, but it will try again of the device name is
    # already taken.
    registerDeviceSafe: (cozyUrl, deviceName, cozyPassword, perms, callback) ->
        log.debug "registerDeviceSafe #{cozyUrl}, #{deviceName}"

        tries = 1
        originalName = deviceName
        registerDevice = Device.registerDevice

        unless callback?
            [perms, callback] = [null, perms]

        tryRegister = (name) ->
            registerDevice cozyUrl, name, cozyPassword, perms, (err, res) ->
                if err is 'This name is already used'
                    tries++
                    tryRegister "#{originalName}-#{tries}"
                else
                    callback err, res

        tryRegister deviceName


    # Unregister device remotely, ask for revocation.
    unregisterDevice: (cozyUrl, deviceName, devicePassword, callback) ->
        log.debug "unregisterDevice #{cozyUrl}, #{deviceName}"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, devicePassword

        client.del "device/#{deviceName}/", (err, res, body) ->
            if err
                callback err
            else if res.statusCode in [200, 204]
                callback null
            else if body.error?
                callback new Error body.error
            else
                callback new Error "Something went wrong (#{res.statusCode})"


    # Send a mail from the user. Can be used to contact support for example.
    # Needs the 'send mail from user' permission
    #
    # mail is composed of:
    # - to, the recipient
    # - subject, a one-line subject
    # - content, the body
    # - attachments, the optional attached files
    sendMailFromUser: (cozyUrl, deviceName, devicePassword, mail, callback) ->
        log.debug "sendMailFromUser #{mail.to}, #{mail.subject}"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, devicePassword

        client.post "ds-api/mail/from-user", mail, (err, res, body) ->
            if res.statusCode is 200
                callback null
            else if err
                callback err
            else if body.error?
                callback new Error body.error
            else
                callback new Error "Something went wrong (#{res.statusCode})"


    # Send a mail to the user. Can be used to send a weekly report for example.
    # Needs the 'send mail to user' permission
    #
    # mail is composed of:
    # - from, the sender
    # - subject, a one-line subject
    # - content, the body
    # - attachments, the optional attached files
    sendMailToUser: (cozyUrl, deviceName, devicePassword, mail, callback) ->
        log.debug "sendMailToUser #{mail.from}, #{mail.subject}"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, devicePassword

        client.post "ds-api/mail/to-user", mail, (err, res, body) ->
            if res.statusCode is 200
                callback null
            else if err
                callback err
            else if body.error?
                callback new Error body.error
            else
                callback new Error "Something went wrong (#{res.statusCode})"


    # Get useful information about the disk space
    # (total, used and left) on the remote Cozy
    getDiskSpace: (cozyUrl, login, password, callback) ->
        log.debug "getDiskSpace #{cozyUrl}, #{login}"

        client = request.newClient cozyUrl
        client.setBasicAuth login, password

        client.get "disk-space", (err, res, body) ->
            if err
                callback err
            else if body.error
                callback new Error body.error
            else
                callback null, body
