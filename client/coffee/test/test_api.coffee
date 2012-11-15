
SchemaManager = require("../schema_manager")

# Imaginary API of a GitHub knockoff

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

    organization:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        plan: {$ref: "#plan"}
        projects:
          type: "object"
          additionalProperties: {$ref: "#project"}
        members:
          type: "array"
          items: {$ref: "#user"}

    plan:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        space: {type: "integer"}
        bandwidth: {type: "integer"}

    user:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        email: {type: "string"}

    project:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        description: {type: "string"}
        refs:
          type: "object"
          properties:
            main: {$ref: "#branch"}
            branches:
              type: "object"
              additionalProperties: {$ref: "#branch"}
            tags:
              type: "array"
              items: {$ref: "#tag"}

    ref:
      extends: {$ref: "#resource"}
      mediaType: "application/json"
      properties:
        name: {type: "string"}
        ref: {type: "string"}
        message: {type: "string"}

    branch:
      extends: {$ref: "#ref"}
      mediaType: "application/json"

    tag:
      extends: {$ref: "#ref"}
      mediaType: "application/json"





resources =
  organization:
    actions:
      get:
        method: "GET"
        response_schema: "organization"
        status: 200
  plan:
    actions:
      get: { method: "GET", response_schema: "plan", status: 200 }
      update: { method: "PUT", response_schema: "plan", status: 200 }

  user:
    actions:
      get: { method: "GET", response_schema: "user", status: 200 }
      update: { method: "GET", response_schema: "user", status: 200 }

  project:
    actions:
      get: { method: "GET", response_schema: "project", status: 200 }
      update: { method: "PUT", response_schema: "project", status: 200 }
      delete: { method: "DELETE", status: 204 }

  ref:
    actions:
      get: { method: "GET", response_schema: "ref", status: 200 }

  branch:
    actions:
      get: { method: "GET", response_schema: "ref", status: 200 }
      rename: { method: "POST", status: 200 }
      delete: { method: "DELETE", status: 204 }

  tag:
    actions:
      get: { method: "GET", response_schema: "ref", status: 200 }
      delete: { method: "DELETE", status: 204 }

directory = {}

SchemaManager.normalize(schema)

module.exports =
  directory: directory
  resources: resources

  schemas: [ schema ]

