JSCK = require "jsck"

patchboard_api = require "./patchboard_api"

module.exports = class SchemaManager

  constructor: (schemas...) ->
    for schema in schemas
      # `definitions` is the conventional place to put schemas,
      # so we'll define fragment IDs by default where they are
      # not explicitly specified.
      if definitions = schema.definitions
        for name, definition of definitions
          definition.id ||= "##{name}"

    @jsck = new JSCK.draft3 patchboard_api.schema, schemas...
    @schemas = [patchboard_api.schema].concat(schemas)
    @uris = @jsck.references

  find: (args...) ->
    @jsck.find(args...)

  document: () ->
    @document_markdown()

  document_markdown: () ->
    out = []
    out.push "# Schemas"
    for uri, schema of @uris
      if string = @schema_doc(uri, schema)
        out.push string
    out.join("\n\n")

  schema_doc: (uri, schema) ->
    lines = []
    if schema.id
      lines.push """
      <a id="#{schema.id.replace("#", "/")}"></a>
      ## #{uri} 
      """
      lines.push """
      ```json
      #{JSON.stringify(schema, null, 2)}
      ```
      """
      lines.join("\n\n")

  #schema: (args...) ->
    #@jsck.validate(args...)

  #validate: (args...) ->
    #@jsck.validate(args...)


  #format_name: (data_uri) ->
    #[root, data_property] = data_uri.split("#/")
    #data_property ?= "<root>"
    #data_property
      #.replace /(\d+)\//g, (match, p1) -> "[#{p1}]/"
      #.replace(/\//g, ".")

  #format_error: (error) ->
    #[root, property] = error.uri.split("#/")
    #schema_property = error.schemaUri.split(":")[2]
    #property ||= "<root>"
    #out =
      #message: error.message
      #schema: schema_property

    #switch error.message
      #when "Instance is not a required type"
        #out.types = error.details
      #when "Number is greater than the required maximum value"
        #out.maximum = error.details
      #when "Number is less than the required minimum value"
        #out.minimum = error.details

    #out

