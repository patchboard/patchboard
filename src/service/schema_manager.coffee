JSV = require("JSV").JSV
patchboard_schema = require("../patchboard_schema")


class SchemaManager

  constructor: (@application_schema) ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")
    @register_schema(patchboard_schema)
    @register_schema(@application_schema)

  register_schema: (schema) ->
    @jsv.createSchema(schema, false, schema.id)

  validate: (type, data) ->
    schema_url = "urn:#{@application_schema.id}##{type}"
    schema = @jsv.findSchema(schema_url)
    if schema
      @jsv.validate data, schema, (error) ->
        console.log(error)
    else
      throw "unknown schema type: #{type}"

  @transform_schemas: (schemas) ->
    primitives =
      "string": true
      "object": true
      "array": true
      "boolean": true
      "number": true


    convert_types = (thing) ->
      for key, value of thing
        if value.type == "object" && value.properties
          convert_types(value.properties)
        else if value.type && !primitives[value.type]
          thing[key] = {$ref: "api##{value.type}"}
        else
          #console.log value

    transformed = {}
    transformed.id = "api"
    transformed.properties = {}

    for name, schema of schemas
      trans = { id: "##{name}"}
      if extender = schema.extends
        delete schema.extends
        if extender.indexOf("patchboard#") == 0
          trans.extends = {$ref: extender}
        else
          trans.extends = {$ref: "api##{extender}"}
      required = schema.required
      delete schema.required

      if schema.media_type
        trans.mediaType = schema.media_type
        delete schema.media_type

      if schema.properties
        convert_types(schema.properties)

      for key, value of schema
        trans[key] = value
      if required
        for key in required
          trans.properties[key].required = true
      transformed.properties[name] = trans
    transformed


module.exports = SchemaManager
