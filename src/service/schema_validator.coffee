JSV = require("JSV").JSV

class SchemaValidator

  constructor: () ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")

  register_schema: (schema) ->
    @jsv.createSchema(schema, false, schema.id)

  get_schema: (type) ->
    if type.indexOf("#") == 0
      schema_url = "urn:#{@application_schema.id}#{type}"
    else
      schema_url = "urn:#{type}"
    @jsv.findSchema(schema_url)

  validate: (type, data) ->
    schema = @get_schema(type)
    if schema
      @jsv.validate data, schema, (error) ->
        console.log(error)
    else
      throw "unknown schema type: #{type}"


module.exports = SchemaValidator

