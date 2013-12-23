cradle = require('cradle')
db = new(cradle.Connection)().database('books')

books = require('google-books-search')

exports.index = (req, res) ->
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
