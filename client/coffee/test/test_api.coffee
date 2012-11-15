
SchemaManager = require("../schema_manager")

schema =
  id: "test"
  type: "object"
  properties:

    resource:
      type: "object"
      properties:
        url:
          type: "string"
          format: "uri"

    dwarf:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        tools:
          type: "array"
          items: {$ref: "#tool"}

    tool:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}

    result:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}

resources =
  dwarf:
    actions:
      get:
        method: "GET"
        response_schema: "dwarf"
        status: 200
  tool:
    actions:
      use:
        method: "POST"
        response_schema: "result"
        status: 200
      discard:
        method: "DELETE"
        status: 204


directory = {}

SchemaManager.normalize(schema)

module.exports =
  directory: directory
  resources: resources

  schemas: [ schema ]

