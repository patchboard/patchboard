require "./json_patch"
log4js = require "log4js"

{validate} = require("patchboard-api")

base_api = require("./base_api")
Documenter = require("./documenter")
Classifier = require("./classifier")
SchemaManager = require("./schema_manager")
Path = require("./path")
Context = require("./context")


class Service

  constructor: (@api, @options={}) ->
    {@decorator} = @options
    @log = @options.log || do ->
      log = log4js.getLogger("Patchboard")
      log.setLevel "DEBUG"
      log
      

    # Validate the API definition against the Patchboard Definition schema
    #report = jsck.validator("urn:patchboard.api#").validate api
    report = validate(@api)
    if !report.valid
      errors = JSON.stringify report.errors, null, 2
      @log.error "Invalid API.  Errors: #{errors}"
      process.exit(1)


    url = @options.url || "http://localhost:1646"
    # We construct full urls by concatenating @url and the path,
    # so make sure that @url does not end in a slash.
    if url[url.length-1] == "/"
      url = url.slice(0,-1)
    @url = url

    @schema_manager = new SchemaManager(@api.schema)
    @mappings = @api.mappings

    @resources = {}
    for key, value of base_api.resources
      @resources[key] = value
    for key, value of @api.resources
      @resources[key] = value


    @directory = {}
    @paths = {}

    for mappings in [base_api.mappings, @mappings]
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

  context:(request, response) ->
    new Context @, request, response

  classify: (args...) ->
    @classifier.classify(args...)

  generate_url: (resource_type, args...) ->
    path = @paths[resource_type]
    if path
      "#{@url}#{path.generate(args...)}"
    else
      throw new Error "Problem generating URL. No such resource: #{resource_type}"


  documentation: () ->
    """
    #{@documenter.document_resources()}
    
    #{@schema_manager.document()}
    """
  

module.exports = Service
