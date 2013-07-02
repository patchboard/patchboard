SchemaManager = require "./schema_manager"

codes =
  "unauthorized": 401
  "forbidden": 403
  "not found": 404
  "conflict": 409

status_code = (description) ->
  if code = codes[description.toLowerCase()]
    code
  else
    500


module.exports = class Context
  constructor: (@service, @request, @response, @match) ->
    {@schema_manager, @log} = @service

  set_cors_headers: (origin) ->
    if @request.headers["origin"]
      origin ||= @request.headers["origin"]
      @response.setHeader "Access-Control-Allow-Origin", origin

  respond: (status, @response_content, headers) ->
    if status == 202 || status == 204 || !@response_content
      @response_content = ""
    headers ||= {}

    if @match.accept
      @response_schema = @schema_manager.find(media_type: @match.accept)
    else
      @response_schema = null

    if @response_content
      @response_content = @marshal(@response_content)

    # Set the content-type and content-length headers explicitly 
    # for the benefit of connect's compress middleware
    @response.setHeader "Content-Length", Buffer.byteLength(@response_content)
    if @match.accept && @response_content.length > 0
      @response.setHeader("Content-Type", @match.accept)
    @response.writeHead(status, headers)
    @response.end(@response_content)

  error: (description) ->
    if description == "timeout"
      @respond(504)
    else
      status = status_code(description)
      @respond(status, description)

  url: (name, args...) ->
    @service.generate_url(name, args...)

  marshal: (content) ->
    if content.constructor == String
      content
    else
      if @service.decorator
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


