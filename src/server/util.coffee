URL = require("url")

parse_url = (url) ->
  parsed = URL.parse(url, true)
  parsed.path = parsed.pathname = parsed.pathname.replace("//", "/")
  parsed

augment_request = (request) ->
  # TODO: replace this with our own Request object, which wraps
  # and supplements the raw Node.js request
  url = parse_url(request.url)
  request.path = url.pathname
  request.query = url.query

module.exports = {parse_url, augment_request}
