express = require('express')
http    = require('http')
Promise = require('bluebird')
hbs = require('express-hbs')
books = require('google-books-search')
_ = require('underscore')
request = require('request')
path = require('path')

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

  setupDb()

  app.use express.bodyParser()

  app.get('/', (req, res) ->
    db.view('books/unseen', (err, docs) ->
      if err?
        return console.error 'Error retrieving book by name'

      book = docs[0]
      books.search(book.key, (err, results) ->
        if err?
          return res.send 500, 'bad'

        res.render 'index', book: book, search_results: results
      )
    )
  )

  app.get('/book/:id', (req, res) ->
    db.get(req.params.id, (err, reply) ->
      if err?
        res.send 500, err

      res.sendfile(reply.path)
    )
  )

  app.post('/book/:id', (req, res) ->
    id = req.params.id
    db.merge(id, _.extend(seen: true, req.body), (err, result) ->
      if err?
        return res.send 500, err

      if req.body.thumbnail? && req.body.thumbnail.length > 0
        attachmentData =
          name: 'thumbnail'
          'Content-Type': 'image/jpeg'
        thumbnailStream = request(req.body.thumbnail)

        writeStream = db.saveAttachment(id, attachmentData, (err, reply) ->
          if err?
            return res.send 500, err

          console.log reply
          res.redirect '/'
        )
        thumbnailStream.pipe(writeStream)
    )
  )

  app.delete('/book/:id', (req, res) ->
    id = req.params.id
    db.remove(id, (err, reply) ->
      if err?
        return res.send 500, err

      res.send 200
    )
  )

  server = http.createServer(app).listen(3000, (err) ->
    if err?
      return deferred.reject(err)

    deferred.resolve(server)
  )

  return deferred.promise

module.exports = startServer
