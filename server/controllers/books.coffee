cradle = require('cradle')
db = new(cradle.Connection)().database('books')

exports.index = (req, res) ->
  res.redirect('/')

exports.create = (req, res) ->
  id = req.params.id
  console.log req.body
  #db.merge(id, _.extend(seen: true, req.body), (err, result) ->
    #if err?
      #return res.send 500, err

    #if req.body.thumbnail? && req.body.thumbnail.length > 0
      #attachmentData =
        #name: 'thumbnail'
        #'Content-Type': 'image/jpeg'
      #thumbnailStream = request(req.body.thumbnail)

      #writeStream = db.saveAttachment(id, attachmentData, (err, reply) ->
        #if err?
          #return res.send 500, err

        #console.log reply
        #res.redirect '/'
      #)
      #thumbnailStream.pipe(writeStream)
  #)

exports.destroy = (req, res) ->
  id = req.params.id
  db.remove(id, (err, reply) ->
    if err?
      return res.send 500, err

    res.send 200
  )

exports.showPdf = (req, res) ->
  db.get(req.params.id, (err, reply) ->
    if err?
      res.send 500, err

    res.sendfile(reply.path)
  )
