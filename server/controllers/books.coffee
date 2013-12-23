cradle = require('cradle')
db = new(cradle.Connection)().database('books')

_ = require('underscore')
request = require('request')

attributeWhitelist = ['name', 'authors', 'thumbnail', 'category']

paramsToAttributes = (params) ->
  attributes = _.pick(params, attributeWhitelist)
  return _.extend(seen: true, attributes)

attachmentData =
  name: 'thumbnail'
  'Content-Type': 'image/jpeg'

thumbnailStreamFromUrl = (url) ->
  return request(url)

exports.create = (req, res) ->
  id = req.params.id

  bookAttributes = paramsToAttributes(req.body)

  console.log bookAttributes

  db.merge(id, bookAttributes, (err, result) ->
    if err?
      return res.send 500, err

    console.log id

    thumbnailUrl = req.body.thumbnail
    if thumbnailUrl? && thumbnailUrl.length > 0
      thumbnailStream = thumbnailStreamFromUrl(thumbnailUrl)

      writeStream = db.saveAttachment(id, attachmentData, (err, reply) ->
        if err?
          return res.send 500, err

        console.log reply
        res.redirect '/'
      )

      thumbnailStream.pipe(writeStream)
    else
      res.redirect '/'
  )

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
