module.exports =
  
  map:
    service:
      paths: ["/"]
      publish: true

  interface:
    service:
      actions:

        documentation:
          method: "GET"

        description:
          method: "GET"
          response_entity: "description"

  schema:
    id: "patchboard"
    properties:
      resource:
        id: "#resource"
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
          interface: {type: "object"}
          directory: {type: "object"}

