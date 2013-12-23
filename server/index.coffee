express = require('express')
http    = require('http')
Promise = require('bluebird')
hbs = require('express-hbs')
_ = require('underscore')
request = require('request')
path = require('path')
setupRoutes = require('./route_bindings')

cradle = require('cradle')
db = new(cradle.Connection)().database('books')

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

setupDb = ->
  db.save('_design/books',
    all:
      map: (doc) ->
        emit(doc.name, doc) if doc.name
    unseen:
      map: (doc) ->
        emit(doc.name, doc) if doc.seen == false
  )

startServer = ->
  deferred = Promise.defer()

  app = express()

  app.engine('hbs', hbs.express3(
    contentHelperName: 'content'
    partialsDir: __dirname + '/views/partials'
  ))
  app.set('view engine', 'hbs')
  app.set('views', __dirname + '/views')
  app.use(express.static(path.join(__dirname, "../", "public")))

  app.use(express.json())
  app.use(express.urlencoded())

  setupDb()
  setupRoutes(app)

  server = http.createServer(app).listen(3000, (err) ->
    if err?
      return deferred.reject(err)

    deferred.resolve(server)
  )

  return deferred.promise

module.exports = startServer
