JSV = require("JSV").JSV

class SchemaValidator

  constructor: (@schema_manager) ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")
    for schema in @schema_manager.schemas
      @jsv.createSchema(schema, false, schema.id)

  validate: (identifier, data) ->
    schema = @schema_manager.find(identifier)
    if schema
      result = @jsv.findSchema(schema.id).validate data, schema
      if result.errors
        result.description = {}
        for error in result.errors
          propname = error.schemaUri.split(":")[2]
          result.description[propname] = error.message
      result
    else
      throw "unknown schema id: #{id}"



module.exports = SchemaValidator

