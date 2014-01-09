module.exports =
  id: "urn:patchboard.api"
  properties:

    schema:
      required: true
      ## TODO: re-enable when JSCK supports remote refs
      #$ref: "http://json-schema.org/draft-03/schema#"

    mappings:
      required: true
      type: "object"
      additionalProperties:
        type: "object"
        additionalProperties: false
        properties:
          description:
            type: "string"
          resource:
            type: "string"
          url:
            type: "string"
          path:
            type: "string"
          template:
            type: "string"
          query:
            ## TODO: re-enable when JSCK supports remote refs
            ## Extend the full JSON schema, so we can constrain the legal
            ## values of "type".
            #extends: {$ref: "http://json-schema.org/draft-03/schema#"}
            properties:
              type:
                enum:
                  ["string", "number", "integer", "boolean"]

    resources:
      required: true
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

              additionalProperties: false
              properties:
                description: {type: "string"}
                method:
                  required: true
                  type: "string"
                  enum: ["GET", "PUT", "POST", "PATCH", "DELETE"]
                request:
                  type: "object"
                  properties:
                    type:
                      title: "The media type to be used for the request"
                      type: "string"
                    authorization:
                      title: "The name of the authorization scheme"
                      type: "string"
                response:
                  type: "object"
                  properties:
                    type:
                      title: "The media type to be used for the request"
                      type: "string"
                    status:
                      title: "The HTTP status code that indicates success"
                      type: "integer"
                      enum: [200, 201, 202, 204]



if require.main == module
  console.log JSON.stringify(module.exports, null, 2)

