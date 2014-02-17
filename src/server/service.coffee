URL = require("url")

#JSCK = require("jsck").draft3
#schema = require("../schema")
#jsck = new JSCK schema
validate = require("../validate")

PatchboardAPI = require("./patchboard_api")
Dispatcher = require("./simple_dispatcher")
Documenter = require("./documenter")
Classifier = require("./classifier")
SchemaManager = require("./schema_manager")
Path = require("./path")

class Service

  constructor: (api, @options={}) ->
    # Validate the API definition against the Patchboard Definition schema
    #report = jsck.validator("urn:patchboard.api#").validate api
    report = validate(api)
    if !report.valid
      errors = JSON.stringify report.errors, null, 2
      console.log "Invalid API.  Errors:", JSON.stringify(report.errors, null, 2)
      process.exit(1)

    {@decorator} = @options
    @log = @options.log || console

    url = @options.url || "http://localhost:1337"
    # We construct full urls by concatenating @url and the path,
    # so make sure that @url does not end in a slash.
    if url[url.length-1] == "/"
      url = url.slice(0,-1)
    @url = url

    @schema_manager = new SchemaManager(api.schema)
    @mappings = api.mappings

    @resources = {}
    for key, value of PatchboardAPI.resources
      @resources[key] = value
    for key, value of api.resources
      @resources[key] = value


    @directory = {}
    @paths = {}

    for mappings in [PatchboardAPI.mappings, @mappings]
      for resource_type, mapping of mappings
        @paths[resource_type] = new Path(mapping)

        if mapping.path
          @directory[resource_type] =
            resource: mapping.resource
            url: "#{@url}#{mapping.path}"
            query: mapping.query
        else if mapping.template
          @directory[resource_type] =
            resource: mapping.resource
            template: "#{@url}#{mapping.template}"
            query: mapping.query
        else if mapping.query
          @directory[resource_type] =
            resource: mapping.resource
            query: mapping.query


    @default_handlers = require("./handlers")(@)
    @classifier = new Classifier(@)
    @documenter = new Documenter(@)

    @description =
      resources: @resources
      schemas: @schema_manager.schemas
      mappings: @directory


  classify: (args...) ->
    @classifier.classify(args...)

  generate_url: (resource_type, args...) ->
    path = @paths[resource_type]
    if path
      "#{@url}#{path.generate(args...)}"
    else
      throw new Error "Problem generating URL. No such resource: #{resource_type}"


  simple_dispatcher: (app_handlers) ->
    handlers = {}

    # TODO: move this logic into the Dispatcher
    # Install Patchboard's default handlers
    for resource, actions of @default_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    for resource, actions of app_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    dispatcher = new Dispatcher(@, handlers)
    dispatcher.request_listener()

  @parse_url: (url) ->
    parsed = URL.parse(url, true)
    parsed.path = parsed.pathname = parsed.pathname.replace("//", "/")
    parsed


  @augment_request: (request) ->
    # TODO: replace this with our own Request object, which wraps
    # and supplements the raw Node.js request
    url = @parse_url(request.url)
    request.path = url.pathname
    request.query = url.query

  augment_request: (request) ->
    @constructor.augment_request(request)

  documentation: () ->
    """
    #{@documenter.document_resources()}
    
    #{@schema_manager.document()}
    """
  

module.exports = Service
