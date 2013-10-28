SchemaManager = require "./schema_manager"

# Map the names to numbers of the codes that are appropriate for a Patchboard
# application to use.  Explanation of missing codes:
#
# 402 is "reserved for future use"
# 405, 406, and 415 statuses are determined wholly by the Patchboard Classifier.
# Patchboard does not yet support the features required for
# 407, 408, 411, 412, 413, 414, and 416.
#
# 501 status is for the HTTP server to notify a client that the HTTP
# method sent in a request is completely unknown, not just unsupported.
# 505 should be handled by the HTTP server used with Patchboard.
codes =
  "bad request": 400
  "unauthorized": 401
  "forbidden": 403
  "not found": 404
  "conflict": 409
  "gone": 410
  "internal server error": 500
  "bad gateway": 502
  "service unavailable": 503
  "gateway timeout": 504


module.exports = class Context
  constructor: (@service, @request, @response, @match) ->
    {@schema_manager, @log} = @service
    if @match.accept
      @response_schema = @schema_manager.find(mediaType: @match.accept)

  set_cors_headers: (origin) ->
    if @request.headers["origin"]
      origin ||= @request.headers["origin"]
      @response.setHeader "access-control-allow-origin", origin

  respond: (status, @response_content="", _headers={}) ->
    # Normalize input headers to lowercase, as it should be legal to
    # pass header keys in any case, and we need to check for the presence
    # of certain headers.
    headers = {}
    for key, value of _headers
      headers[key.toLowerCase()] = value

    if status == 202 || status == 204
      # Clobber content and header for status codes where a body is not allowed.
      @response_content = ""
      delete headers["content-type"]

    else if status < 400 && @match.accept?
      headers["content-type"] ||= @match.accept

    content = @marshal(@response_content)

    # Must set the content-type and content-length headers explicitly 
    # for the benefit of connect's compress middleware.
    @response.setHeader "content-length", Buffer.byteLength(content)
    for key, value of headers
      @response.setHeader key, value

    @response.writeHead(status)
    @response.end(content)


  error: (name, message) ->
    if status = codes[name.toLowerCase()]
      @respond status, {name: name, message: message},
        "content-type": "application/json"
    else
      @respond 500, {name: "internal server error", message: name},
        "content-type": "application/json"

  url: (name, args...) ->
    @service.generate_url(name, args...)

  marshal: (content) ->
    if content.constructor == String
      content
    else
      if @response_schema && @service.decorator
        @service.decorator
          service: @service
          context: @
          response_schema: @response_schema
          response_content: content
      JSON.stringify(content)

  decorate: (callback) ->
    @traverse(@response_schema, @response_content, callback)

  traverse: (schema, data, callback) ->
    if callback && schema
      callback(schema, data)
    @_traverse(schema, data, callback)

  _traverse: (schema, data, callback) ->
    return unless schema && data

    if ref = schema.$ref
      if schema = @schema_manager.find(ref)
        @traverse(schema, data, callback)
      else
        @log.error "Can't find ref:", ref
    else
      if schema.type == "array"
        if schema.items
          for item, i in data
            @traverse(schema.items, item, callback)
      else if !schema.is_primitive
        additional_schema = schema.additionalProperties
        for key, value of data
          property_schema = schema.properties?[key] || additional_schema
          if property_schema
            @traverse(property_schema, value, callback)


