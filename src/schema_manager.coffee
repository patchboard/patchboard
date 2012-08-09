class SchemaManager

  #constructor: (@application_schema) ->
  constructor: (@schemas...) ->
    # "flat" storage of schemas, using absolute names
    @names = {}
    @ids = {}
    @media_types = {}

    for schema in @schemas
      @register_schema(schema)


  register_schema: (schema) ->
    for name, definition of schema.properties
      @inherit_properties(definition)

      @names[name] = definition
      # NOTE: adding the name to the @ids object is a hack to support
      # some complex changes in the client. TODO: remove it.
      #@ids[name] = definition
      if definition.id
        @ids[definition.id] = definition
      if definition.mediaType
        @media_types[definition.mediaType] = definition


  inherit_properties: (schema) ->
    if schema.extends
      parent_id = schema.extends.$ref
      parent = @ids[parent_id]
      if parent
        merged = {properties: {}}
        for key, value of parent.properties
          merged.properties[key] = value
        for key, value of schema.properties
          merged.properties[key] = value
        schema.properties = merged.properties
      else
        throw "Could not find parent schema: #{parent_id}"



  document: () ->
    @document_markdown()

  document_markdown: () ->
    out = []
    out.push "# Schemas"
    for name, schema of @names
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
