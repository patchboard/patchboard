module.exports =
  
  mappings:
    service:
      path: "/"
      resource: "service"

  resources:
    service:
      actions:

        documentation:
          method: "GET"
          status: 200

        description:
          method: "GET"
          response:
            type: "application/json"
            status: 200

  schema:
    id: "urn:patchboard"
    definitions:
      resource:
        id: "#resource"
        type: "object"
        properties:
          url:
            type: "string"
            format: "uri"
            readonly: true
      service:
        extends: {$ref: "urn:patchboard#resource"}
        id: "#service"

      description:
        id: "#description"
        type: "object"
        mediaType: "application/json"
        properties:
          schema: {type: "object"}
          resources: {type: "object"}
          directory: {type: "object"}

