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
          request_entity: "attachment_list"

    attachment:
      actions:
        get:
          method: "GET"
          response_entity: "attachment"
        delete:
          method: "DELETE"
          authorization: "Basic"

  schema:
    id: "my_api"
    properties:

      resource_collection:
        extends: "resource"
        mediaType: "patchboard.resource_collection"
        properties:
          some_property: {type: "string"}

      resource_instance:
        extends: "resource"
        mediaType: "patchboard.resource_instance"
        properties:
          some_property: {type: "string"}

      attachments:
        extends: "resource"
        mediaType: "patchboard.attachments"

      attachment:
        extends: "resource"
        mediaType: "patchboard.attachment"
        properties:
          some_property: {type: "string"}

