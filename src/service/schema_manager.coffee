JSV = require("JSV").JSV
rigger_schema =
  id: "rigger"
  properties:
    resource:
      id: "#resource"
      type: "object"
      properties:
        url:
          type: "string"
          format: "uri"
          readonly: true

class SchemaManager

  constructor: (@application_schema) ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")
    @register_schema(rigger_schema)
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



module.exports = SchemaManager
