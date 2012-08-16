JSV = require("JSV").JSV

class SchemaValidator

  constructor: (@schema_manager) ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")
    for schema in @schema_manager.schemas
      @jsv.createSchema(schema, false, schema.id)

  get_schema: (id) ->
    schema_url = "urn:#{id}"
    @jsv.findSchema(schema_url)

  validate: (id, data) ->
    schema = @get_schema(id)
    if schema
      @jsv.validate data, schema, (error) ->
        console.log(error)
    else
      throw "unknown schema id: #{id}"


module.exports = SchemaValidator

