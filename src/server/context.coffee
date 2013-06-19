SchemaManager = require "./schema_manager"
status_code = (description) ->
  # FIXME.  Probably use http.STATUS_CODES inverted.
  return 500


module.exports = class Context
  constructor: (@service, @request, @response, @match) ->

  set_cors_headers: (origin) ->
    if @request.headers["origin"]
      origin ||= @request.headers["origin"]
      @response.setHeader "Access-Control-Allow-Origin", origin

  respond: (status, content, headers) ->
    if status == 202 || status == 204 || !content
      content = ""
    headers ||= {}
    content = @marshal(content)

    # Set the content-type and content-length headers explicitly 
    # for the benefit of connect's compress middleware
    # headers["Content-Length"] = Buffer.byteLength(content)
    @response.setHeader "Content-Length", Buffer.byteLength(content)
    if @match.accept && content.length > 0
      # headers["Content-Type"] ||= @match.accept
      @response.setHeader("Content-Type", @match.accept)
    @response.writeHead(status, headers)
    @response.end(content)

  error: (description) ->
    if description == "timeout"
      @respond(504)
    else
      status = status_code(description)
      @respond(status, description)

  url: (name, args...) =>
    @service.generate_url(name, args...)

  marshal: (content) ->
    if content.constructor == String
      content
    else
      if @match.accept
      #if @service.response_decorator && @match.accept
        schema = @service.schema_manager.find(media_type: @match.accept)
        @service.decorate(@, schema, content)
      JSON.stringify(content, null, 2)


  #decorate: (schema, data) ->
    #@service.response_decorator(@, schema, data)
    #@_decorate(schema, data)

  #_decorate: (schema, data) ->
    #if !schema || !data
      #return
    #if ref = schema.$ref
      #if schema = @service.schema_manager.find(ref)
        #@decorate(schema, data)
      #else
        #console.error "Can't find ref:", ref
        #data
    #else
      #if schema.type == "array"
        #if schema.items
          #for item, i in data
            #@decorate(schema.items, item)
      #else if !SchemaManager.is_primitive(schema.type)
        ## Declared properties
        #for key, value of schema.properties
          #@decorate(value, data[key])
        ## Default for undeclared properties
        #if addprop = schema.additionalProperties
          #for key, value of data
            #unless schema.properties?[key]
              #@decorate(addprop, value)
        #return data



