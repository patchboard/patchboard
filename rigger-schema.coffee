module.exports =
  # TODO: figure out how to define a "dictionary" type
  resource:
    id: "resource"
    extends: { $ref: "http://json-schema.org/draft-04/schema#" }
    properties:
      url: {type: "string"}
    required: ["url"]
