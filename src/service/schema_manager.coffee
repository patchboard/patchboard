patchboard_schema = require("../patchboard_api").schema

class SchemaManager

  constructor: (@application_schema) ->
    # "flat" storage of schemas, using absolute names
    @schemas = {}

    @normalize(patchboard_schema)
    @normalize(@application_schema)

    @register_schema(patchboard_schema)
    @register_schema(@application_schema)

  normalize: (schema) ->
    for name, definition of schema.properties
      if definition.id && definition.id.indexOf("#") == 0
        definition.id = "#{schema.id}#{definition.id}"
      else
        definition.id = "#{schema.id}##{name}"

      if definition.extends
        if definition.extends.$ref && definition.extends.$ref.indexOf("#") == 0
          definition.extends.$ref = "#{schema.id}#{definition.extends.$ref}"


  # Stows each subschema in a dict under its name and id.
  # The ids should be unique, but names can easily end with surprising 
  # overrides, so this needs to be used as Last One Wins.
  # The primary reason for using the bare "name" is so that Patchboard
  # HTTP interface specs can refer to them.
  # The reason to store the fully qualified ids is to allow bog standard
  # JSON schema validators to work.
  register_schema: (schema) ->
    for name, definition of schema.properties
      @schemas[name] = definition
      if definition.id
        @schemas[definition.id] = definition

  document: () ->
    @document_markdown()

  document_markdown: () ->
    out = []
    out.push "# Schemas"
    for name, schema of @schemas
      out.push @schema_doc(name, schema)
    out.join("\n\n")

  schema_doc: (name, schema) ->
    lines = []
    lines.push """
    <a id="#{schema.id.replace("#", "/")}"></a>
    ## #{name} 
    """
    lines.push """
    ```json
    #{JSON.stringify(schema, null, 2)}
    ```
    """
    lines.join("\n\n")

module.exports = SchemaManager
