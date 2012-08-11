class SchemaManager

  @normalize: (schema, namespace) ->
    namespace ||= schema.id
    if schema.$ref && schema.$ref.indexOf("#") == 0
      schema.$ref = "#{namespace}#{schema.$ref}"

    for name, definition of schema.properties
      if definition.id
        if definition.id.indexOf("#") == 0
          definition.id = "#{namespace}#{definition.id}"
      else
        definition.id = "#{namespace}##{name}"

      if definition.extends
        if definition.extends.$ref && definition.extends.$ref.indexOf("#") == 0
          definition.extends.$ref = "#{namespace}#{definition.extends.$ref}"

      if definition.type == "array" && definition.items.$ref.indexOf("#") == 0
        definition.items.$ref = "#{namespace}#{definition.items.$ref}"

      if definition.type == "object" && definition.additionalProperties?.$ref?.indexOf("#") == 0
        definition.additionalProperties.$ref = "#{namespace}#{definition.additionalProperties.$ref}"

      if definition.$ref && definition.$ref.indexOf("#") == 0
        definition.$ref = "#{namespace}#{definition.$ref}"

      for prop_name, prop_def of definition.properties
        @normalize(prop_def, namespace)

  @is_primitive: (type) ->
    for name in ["string", "number", "boolean"]
      return true if type == name
    return false



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
