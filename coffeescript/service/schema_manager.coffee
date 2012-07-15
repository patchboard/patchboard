JSV = require("JSV").JSV

#amanda = require("amanda")

class SchemaManager

  constructor: (@schemas) ->
    @validator = JSV.createEnvironment()

  validate: (type, data) ->
    schema = @schemas[type]
    if schema
      @validator.validate data, schema, (error) ->
        console.log(error)
    else
      throw "unknown schema type: #{type}"



module.exports = SchemaManager
