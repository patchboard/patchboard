module.exports =
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
