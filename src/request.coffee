URL = require("url")

parse_url = (url) ->
  parsed = URL.parse(url, true)
  parsed.path = parsed.pathname = parsed.pathname.replace("//", "/")
  parsed

parse_authorization = (string) ->
  [scheme, credentials] = string.split(" ")
  if scheme == "Basic"
    decoded = Buffer(credentials, "base64").toString("ascii")
    [login, password] = decoded.split(":")
    params = {login, password}
  else
    params = parse_auth_params(credentials)
  {scheme, params}

parse_auth_params = (string) ->
  params = {}
  parts = string.split(",")
  for part in parts
    [key, value] = part.split("=")
    # values may be tokens or quoted strings
    if (match = value.match /^"(.*)"$/)?
      params[key] = match[1]
    else
      params[key] = value

  params

module.exports = class Request

  constructor: (@raw) ->
    url = parse_url(@raw.url)
    @path = url.pathname

    for key, value of @raw.headers
      if value == "__proto__"
        throw new Error "One of the headers contained value '__proto__'"

    for key, value of url.query
      if value == "__proto__"
        throw new Error "Query parameters contained value '__proto__'"
    @query = url.query

    @method = @raw.method
    @headers = @raw.headers
    @body =  @raw.body
    auth_string = @headers["Authorization"] || @headers["authorization"]
    if auth_string?
      @authorization = parse_authorization(auth_string)
    @content_type = @headers["content-type"] || @headers["Content-Type"]
    @accept =  @headers["accept"] || @headers["Accept"]

