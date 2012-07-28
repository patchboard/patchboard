module.exports =
  
  map:
    patchboard:
      paths: ["/"]

  interface:
    patchboard:
      actions:

        documentation:
          method: "GET"

        service_description:
          method: "GET"
          accept: "application/json"

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

