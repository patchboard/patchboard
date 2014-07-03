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
  for key, value of request.headers
    if value == "__proto__"
      throw new Error "One of the headers contained value '__proto__'"

  for key, value of url.query
    if value == "__proto__"
      throw new Error "Query parameters contained value '__proto__'"
  request.query = url.query


module.exports = {parse_url, augment_request}
