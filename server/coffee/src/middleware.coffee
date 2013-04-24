# Adapted from the JSON middleware that comes with Connect

utils = require("connect/lib/utils")

json_regex = /\+json$/

exports.json = (options) ->
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

    request._body = true

    buf = ""
    request.setEncoding("utf8")
    request.on "data", (chunk) -> buf += chunk
    request.on "end", ->
      if !(buf[0] == "{" || buf[0] == "[")
        return next(utils.error(400))
      try
        request.body = JSON.parse(buf)
        next()
      catch err
        err.status = 400
        next(err)


