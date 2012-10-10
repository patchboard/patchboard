status_code = (description) ->
  # FIXME.  Probably use http.STATUS_CODES inverted.
  return 500


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
    headers["Content-Length"] = Buffer.byteLength(content)
    if @match.accept && content.length > 0
      headers["Content-Type"] ||= @match.accept
    @response.writeHead(status, headers)
    @response.end(content)

  error: (description) ->
    if description == "timeout"
      @respond(504)
    else
      status = status_code(description)
      @respond(status, description)

module.exports = Context

