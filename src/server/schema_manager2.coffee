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

  schema: (args...) ->
    @jsck.validate(args...)

  validate: (args...) ->
    @jsck.validate(args...)

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

