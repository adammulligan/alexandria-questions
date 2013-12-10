express = require('express')
http    = require('http')
whenjs    = require('when')

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

startServer = (callback) ->
  deferred = whenjs.defer()

  app = express()

  server = http.createServer(app).listen(3000, (err) ->
    if err?
      return deferred.reject(err)

    deferred.resolve(server)
  )

  return deferred.promise

module.exports = startServer
