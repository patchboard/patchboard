class Context
  constructor: (@request, @response, @match) ->

  set_cors_headers: (origin) ->
    if @request.headers["origin"]
      origin ||= @request.headers["origin"]
      @response.setHeader "Access-Control-Allow-Origin", origin

  respond: (status, content, headers) ->
    if status == 202 || status == 204 || !content
      content = ""
    headers ||= {}
    if content.constructor != String
      content = JSON.stringify(content)
    headers["Content-Length"] = content.length
    if @match.accept
      headers["Content-Type"] ||= @match.accept
    @response.writeHead(status, headers)
    @response.end(content)

module.exports = Context

