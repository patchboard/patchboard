JSV = require("JSV").JSV

class SchemaValidator

  constructor: (@schema_manager) ->
    @jsv = JSV.createEnvironment("json-schema-draft-03")
    for schema in @schema_manager.schemas
      @jsv.createSchema(schema, false, schema.id)

  validate: (identifier, data) ->
    schema = @schema_manager.find(identifier)
    if schema
      result = @jsv.findSchema(schema.id).validate data
      if result.errors
        result.description = {}
        for error in result.errors
          data_property = @format_name(error.uri)
          result.description[data_property] = @format_error(error)
      result
    else
      throw "unknown schema identifier: #{identifier}"


  format_name: (data_uri) ->
    [root, data_property] = data_uri.split("#/")
    data_property ?= "<root>"
    data_property
      .replace /(\d+)\//g, (match, p1) -> "[#{p1}]/"
      .replace(/\//g, ".")

  format_error: (error) ->
    [root, property] = error.uri.split("#/")
    schema_property = error.schemaUri.split(":")[2]
    property ||= "<root>"
    out =
      message: error.message
      schema: schema_property

    switch error.message
      when "Instance is not a required type"
        out.types = error.details
      when "Number is greater than the required maximum value"
        out.maximum = error.details
      when "Number is less than the required minimum value"
        out.minimum = error.details

    out


module.exports = SchemaValidator

