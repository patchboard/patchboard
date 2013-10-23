module.exports =
  
  mappings:
    service:
      path: "/"

  resources:
    service:
      actions:

        documentation:
          method: "GET"
          status: 200

        description:
          method: "GET"
          response_schema: "description"
          status: 200

  schema:
    id: "patchboard"
    definitions:
      resource:
        type: "object"
        properties:
          url:
            type: "string"
            format: "uri"
            readonly: true
      service:
        extends: {$ref: "#/definitions/resource"}

      description:
        type: "object"
        mediaType: "application/json"
        properties:
          schema: {type: "object"}
          resources: {type: "object"}
          directory: {type: "object"}

