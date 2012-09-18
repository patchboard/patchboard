class SchemaManager

  @is_primitive: (type) ->
    for name in ["string", "number", "boolean"]
      return true if type == name
    return false

  constructor: (@schemas...) ->
    @names = {} # the part after the fragment identifier
    @ids = {}
    @media_types = {}

    for schema in @schemas
      @register_schema(schema)

  find: (options) ->
    if options.constructor == String
      if options.indexOf("#") > 0
        options = {id: options}
      else
        options = {name: options}

    if id = options.id
      if id.indexOf(":") == -1
        id = SchemaManager.urnize(id)
      @ids[id]
    else if options.media_type
      @media_types[options.media_type]
    else if options.name
      @names[options.name]


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


module.exports = SchemaManager
