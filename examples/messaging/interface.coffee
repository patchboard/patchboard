module.exports =
  "/accounts":
    resource: "account_collection"
    description: "The collection of accounts"
    actions:
      create:
        method: "POST"
        request_entity: "account"
        response_entity: "session"
      search:
        method: "GET"
        query:
          required:
            email: {type: "glob"}
            limit: {type: "integer"}
        response_entity: "account_collection"

  "/accounts/:account_id":
    resource: "account"
    description: "The account resource"
    actions:
      update:
        method: "PUT"
        request_entity: "account"
        response_entity: "account"
        authorization: "Capability"
      delete:
        method: "DELETE"
        authorization: "Basic"

  "/accounts/:account_id/channels":
    resource: "channel_collection"
    description: "The collection of channels for a particular account"
    actions:
      search:
        method: "GET"
        query:
          required:
            name:
              description: "Search for channels by name"
              type: ["glob"]
        response_entity: "channel_collection"
        authorization: "Capability"

      all:
        method: "GET"
        response_entity: "channel_collection"
        authorization: "Capability"


      create:
        method: "POST"
        request_entity: "channel"
        response_entity: "channel"
        authorization: "Capability"

  "/accounts/:account_id/channels/:channel_id":
    resource: "channel"
    description: "The channel resource"
    actions:
      get:
        method: "GET"
        authorization: "Capability"
        response_entity: "channel"
      update:
        method: "PUT"
        authorization: "Capability"
        request_entity: "channel"
        response_entity: "channel"
      delete:
        method: "DELETE"
        authorization: "Capability"



