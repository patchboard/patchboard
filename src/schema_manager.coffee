class SchemaManager

  @urnize: (identifier) ->
    "urn:json:#{identifier}"

  @normalize: (schema) ->
    # TODO: make sure this is idempotent, just in case it gets called twice
    # on the same schema.  Also: do try not to call this twice on the same
    # schema
    # TODO LATER: make this non-destructive
    schema.id = @urnize(schema.id)
    @top_level_ids(schema.properties, schema.id)
    @normalize_properties(schema.properties, schema.id)

  @top_level_ids: (properties, namespace) ->
    for name, schema of properties
      if schema.id
        if schema.id.indexOf("#") == 0
          schema.id = "#{namespace}#{schema.id}"
      else
        schema.id = "#{namespace}##{name}"

  @normalize_properties: (properties, namespace) ->
    for name, definition of properties
      @normalize_schema(name, definition, namespace)

  @normalize_schema: (name, schema, namespace) ->
    # TODO: assess whether we care at all about additional attrs:
    # * disallow
    # * dependencies

    if schema.$ref
      # This schema is a reference to another schema
      @normalize_ref(schema, namespace)
    else if schema.extends?
      # This schema extends (a.k.a. inherits from) another schema
      @normalize_ref(schema.extends, namespace)
    else if schema.type == "array"
      @normalize_array(schema, namespace)
    else if schema.type == "object"
      @normalize_object(schema, namespace)

    if schema.properties
      @normalize_properties(schema.properties, namespace)


  @normalize_extends: (schema, namespace) ->
    # TODO: "extends" can be a schema or an array of schemas
    if schema.$ref
      @normalize_ref(schema, namespace)

  @normalize_array: (schema, namespace) ->
    if schema.items?.$ref
      @normalize_ref(schema.items, namespace)
    if schema.additionalItems?.$ref
      @normalize_ref(schema.additionalItems, namespace)

  @normalize_object: (schema, namespace) ->
    if schema.additionalProperties?.$ref
      @normalize_ref(schema.additionalProperties, namespace)

  @normalize_ref: (schema, namespace) ->
    index = schema.$ref.indexOf("#")
    if index == 0
      schema.$ref = "#{namespace}#{schema.$ref}"
    else if index != -1
      schema.$ref = @urnize(schema.$ref)

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

  find: (options) ->
    if id = options.id
      if id.indexOf(":") == -1
        id = SchemaManager.urnize(id)
      @ids[id]
    else if options.media_type
      @media_types[options.media_type]


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
        console.log schema
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
