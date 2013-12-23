cradle = require('cradle')
db = new(cradle.Connection)().database('books')

booksApi = require('./controllers/books')
dashboard = require('./controllers/dashboard')

module.exports = (app) ->
  app.get('/', dashboard.index)

  app.get('/books/:id.pdf', booksApi.showPdf)
  app.post('/books/:id', booksApi.create)
  app.delete('/books/:id', booksApi.destroy)
