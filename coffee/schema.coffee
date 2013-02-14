module.exports =
  id: "https://github.com/automathew/patchboard-spec"
  properties:
    schema: {$ref: "http://json-schema.org/draft-03/schema#"}
    query:
      id: "#query"
      # Extend the full JSON schema, so we can constrain the legal
      # values of "type".
      extends: {$ref: "http://json-schema.org/draft-03/schema#"}
      properties:
        type:
          enum:
            ["string", "number", "integer", "boolean"]

    paths:
      type: "object"
      additionalProperties:
        type: "object"
        properties:
          path:
            type: "string"
            required: true
          publish:
            type: "boolean"

    resources:
      type: "object"
      description: "A dictionary of resource descriptions"

      additionalProperties:
        type: "object"
        description: "A resource. Name is inferred from the property key"

        properties:
          actions:
            type: "object"
            description: "A dictionary of actions"

            additionalProperties:
              type: "object"
              description: "An action on a resource. Name is inferred from the property key"

              properties:
                description: {type: "string"}
                method:
                  required: true
                  type: "string"
                  enum: ["GET", "PUT", "POST", "PATCH", "DELETE"]
                query:
                  type: "object"
                  properties:
                    optional: {$ref: "#query"}
                    required: {$ref: "#query"}
                request_schema:
                  type: "string"
                  description: "The name of the schema describing the request body"
                response_schema:
                  type: "string"
                  description: "The name of the schema describing the response body"
                status:
                  type: "integer"
                  description: "The HTTP status code that indicates a succesful response for this action"
                  enum: [200, 201, 202, 204]



if require.main == module
  console.log JSON.stringify(module.exports, null, 2)

