cradle = require('cradle')
db = new(cradle.Connection)().database('books')
fs = require('fs')
path = require('path')
_ = require('underscore')

db.exists( (err, exists) ->
  if err?
    return console.log 'error', err

  db.create() unless exists
)

db.save('_design/books',
  all:
    map: (doc) ->
      emit(doc.name, doc) if doc.name
)

db.view('books/all', key: 'Security Engineering 2008', (err, doc) ->
  if err?
    return console.error 'Error retrieving book by name'

  console.log doc
)

###
spawn = require('child_process').spawn
filename = process.argv[2]

files = []

find = spawn('find', [ filename ])
find.stdout.on('data', (data) ->
  files.push(data.toString())
)

find.stderr.on('data', (data) ->
  console.log 'STDERR', data.toString()
  process.exit(1)
)

stripExtension = (file) ->
  file.replace(/\.[^/.]+$/, "")

isHiddenFile = (file) ->
  /^\./.test(file)

fileExtensionWhitelist = ['.epub', '.mobi', '.pdf', '.djvu', '.chm']

find.on('close', (code) ->
  files = files.join('').split('\n')
  files = _.reject(files, (file) ->
    return (
      !fs.existsSync(file) ||
      fs.lstatSync(file).isDirectory() ||
      isHiddenFile(path.basename(file)) ||
      path.extname(file) not in fileExtensionWhitelist
    )
  )

  fileDocs = []

  _.each(files, (file) ->
    filename = stripExtension(path.basename(file))
    fileDocs.push(
      path: file
      name: filename
      seen: false
    )
  )

  db.save(fileDocs, (err, res) ->
    if err?
      console.error 'Could not save docs because:'
      console.error err
      process.exit(0)

    console.log 'saved'
  )

  console.log fileDocs.length
)
###
