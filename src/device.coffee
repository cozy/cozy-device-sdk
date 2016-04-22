request = require 'superagent'
log     = require('printit')
    prefix: 'device'


# Some methods to discuss with a cozy stack
module.exports = Device =

    # Pings the URL to check if it is a Cozy
    pingCozy: (cozyUrl, callback) ->
        log.debug "pingCozy #{cozyUrl}"

        client = request.get "#{cozyUrl}/status"
        client.end (err, res) ->
            if res?.statusCode isnt 200
                callback new Error "No cozy at this URL"
            else
                callback()


    # Pings the cozy to check the credentials without creating a device
    checkCredentials: (cozyUrl, cozyPassword, callback) ->
        log.debug "checkCredentials #{cozyUrl}"

        data =
            login: 'owner'
            password: cozyPassword

        client = request
            .post "#{cozyUrl}/login"
            .send data
        client.end (err, res) ->
            if res?.statusCode isnt 200
                err = err?.message or res.body.error or res.body.message
            callback err


    # Register device remotely then returns credentials given by remote Cozy.
    # This credentials will allow the device to access to the Cozy database.
    registerDevice: (cozyUrl, deviceName, cozyPassword, callback) ->
        log.debug "registerDevice #{cozyUrl}, #{deviceName}"

        client = request
            .post "#{cozyUrl}/device"
            .auth 'owner', cozyPassword
            .send {login: deviceName}
        client.end (err, res) ->
            if err
                callback err
            else if res.body.error?
                callback res.body.error
            else
                callback null,
                    id: res.body.id
                    deviceName: deviceName
                    password: res.body.password


    # Same as registerDevice, but it will try again of the device name is
    # already taken.
    registerDeviceSafe: (cozyUrl, deviceName, devicePassword, callback) ->
        log.debug "registerDeviceSafe #{cozyUrl}, #{deviceName}"

        tries = 1
        originalName = deviceName

        tryRegister = (name) ->
            Device.registerDevice cozyUrl, name, devicePassword, (err, res) ->
                if err is 'This name is already used'
                    tries++
                    tryRegister "#{originalName}-#{tries}"
                else
                    callback err, res

        tryRegister deviceName


    # Unregister device remotely, ask for revocation.
    unregisterDevice: (cozyUrl, deviceName, devicePassword, callback) ->
        log.debug "unregisterDevice #{cozyUrl}, #{deviceName}"

        client = request
            .del "#{cozyUrl}/device/#{deviceName}"
            .auth deviceName, devicePassword
        client.end (err, res) ->
            if res.statusCode in [200, 204]
                callback null
            else if err
                callback err
            else if res.body.error?
                callback new Error res.body.error
            else
                callback new Error "Something went wrong (#{res.statusCode})"


    # Get useful information about the disk space
    # (total, used and left) on the remote Cozy
    getDiskSpace: (cozyUrl, login, password, callback) ->
        log.debug "getDiskSpace #{cozyUrl}, #{login}"

        client = request
            .get "#{cozyUrl}/disk-space"
            .auth login, password
        client.end (err, res) ->
            if err
                callback err
            else if res.body.error
                callback new Error res.body.error
            else
                callback null, res.body
