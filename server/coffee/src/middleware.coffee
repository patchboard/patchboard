zlib = require("zlib")
utils = require("connect/lib/utils")
json_regex = /\+json$/

module.exports =

  request_encoding: (options) ->
    (request, response, next) ->
      encoding = request.headers["content-encoding"]
      if encoding && encoding != "identity"
        #if encoding == "gzip" || encoding == "deflate"
        # FIXME: verify that encoding is either gzip or deflate
        buffers = []
        request.on "data", (chunk) ->
          buffers.push(chunk)
        request.on "end", ->
          buffer = Buffer.concat(buffers)
          zlib.unzip buffer, (error, result) ->
            if error
              error.status = 400
              next(error)
            else
              request._raw_body = result.toString()
              next()
      else
        next()


# Adapted from the JSON middleware that comes with Connect

  json: (options) ->
    (request, response, next) ->
      if request._body
        return next()

      request.body ||= {}

      # Ignore methods which should not have bodies.
      method = request.method
      if method == "GET" || method == "HEAD" || method == "OPTIONS"
        return next()

      string = request.headers["content-type"] || ""
      media_type = string.split(";")[0]
      if !(media_type == "application/json" || json_regex.test(media_type))
        return next()

      # flag as parsed
      request._body = true
      parse_json = (string) ->
        if !(string[0] == "{" || string[0] == "[")
          return next(utils.error(400))
        try
          request.body = JSON.parse(string)
          next()
        catch err
          err.status = 400
          next(err)

      if request._raw_body
        parse_json(request._raw_body)
      else
        buffers = []
        request.on "data", (buffer) ->
          buffers.push(buffer)
        request.on "end", ->
          string = Buffer.concat(buffers).toString()
          parse_json(string)




