module.exports =
  service_url: "http://patchboarded.com"
  map:
    resource_collection:
      paths: ["/resources"]
    resource_instance:
      paths: ["/resources/:id"]
    attachments:
      paths: ["/resources/:id/attachments"]
    attachment:
      paths: ["/resources/:id/attachments/:attachment_id"]


  interface:
    resource_collection:
      actions:
        create:
          method: "POST"
          request_entity: "resource_instance"
          response_entity: "resource_instance"
        list:
          method: "GET"
          response_entity: "resource_collection"
        search:
          method: "GET"
          response_entity: "resource_collection"
          query:
            required:
              name: {type: "string"}
            optional:
              reverse: {type: "boolean"}

    resource_instance:
      actions:
        get:
          method: "GET"
          response_entity: "resource_instance"
        delete:
          method: "DELETE"
          authorization: "Basic"

    attachments:
      actions:
        create:
          method: "POST"
          request_entity: "attachment"
        list:
          method: "GET"
          response_entity: "attachment_list"
        search:
          method: "GET"
          response_entity: "attachment_list"
          query:
            required:
              name: {type: "string"}
            optional:
              reverse: {type: "boolean"}

    attachment:
      actions:
        get:
          method: "GET"
          response_entity: "attachment"
        delete:
          method: "DELETE"
          authorization: "Basic"

  schema:
    id: "api"
    properties:

      resource_collection:
        extends: {$ref: "patchboard#resource"}
        mediaType: "api.resource_collection"
        properties:
          some_property: {type: "string"}

      resource_instance:
        extends: {$ref: "patchboard#resource"}
        mediaType: "api.resource_instance"
        properties:
          expected: {type: "string", required: true}
          optional: {type: "string"}
        additionalProperties: false

      attachment:
        extends: {$ref: "patchboard#resource"}
        mediaType: "api.attachment"
        properties:
          expected: {type: "string", required: true}
          optional: {type: "string"}

      attachment_list:
        mediaType: "api.attachment_list"
        items: {$ref: "#attachment"}

