class Context
  constructor: (@request, @response, @match) ->

  set_cors_headers: (origin) ->
    if @request.headers["origin"]
      origin ||= @request.headers["origin"]
      @response.setHeader "Access-Control-Allow-Origin", origin

  respond: (status, content, headers) ->
    content ||= ""
    headers ||= {}
    if content.constructor != String
      content = JSON.stringify(content)
    headers["Content-Length"] = content.length
    @response.writeHead(status, headers)
    @response.end(content)

module.exports = Context

