module.exports =
  
  paths:
    service:
      path: "/"
      publish: true

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
    properties:
      resource:
        type: "object"
        properties:
          url:
            type: "string"
            format: "uri"
            readonly: true
      service:
        extends: {$ref: "#resource"}

      description:
        type: "object"
        mediaType: "application/json"
        properties:
          schema: {type: "object"}
          resources: {type: "object"}
          directory: {type: "object"}

