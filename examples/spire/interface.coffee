module.exports =

  "/accounts":
    resource: "account_collection"
    description: "The collection of accounts"
    actions:
      create:
        method: "POST"
        request_entity: "account"
        response_entity: "session"

  "/accounts/:account_id":
    resource: "account"
    description: "The account resource"
    actions:
      get:
        method: "GET"
        response_entity: "account"
        authorization: "Capability"
      update:
        method: "PUT"
        request_entity: "account"
        response_entity: "account"
        authorization: "Capability"
      reset:
        method: "POST"
        response_entity: "account"
      delete:
        method: "DELETE"
        authorization: "Capability"

  "/sessions":
    resource: "session_collection"
    description: "The place to get sessions from"
    actions:
      create:
        method: "POST"
        request_entity: "account"
        response_entity: "session"

  "/account/:account_id/session/:session_id":
    resource: "session"
    actions:
      get:
        method: "GET"
        response_entity: "session"
        authorization: "Capability"
      delete:
        method: "DELETE"
        authorization: "Capability"

  "/accounts/:account_id/channels":
    resource: "channel_collection"
    description: "The collection of channels for a particular account"
    actions:
      get_by_name:
        method: "GET"
        query:
          required:
            name:
              description: "Search for channels by name"
              type: "string"
        response_entity: "channel_dictionary"
        authorization: "Capability"
      all:
        method: "GET"
        response_entity: "channel_dictionary"
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
      publish:
        method: "POST"
        authorization: "Capability"
        request_entity: "message"
        response_entity: "message"
      delete:
        method: "DELETE"
        authorization: "Capability"

  "/accounts/:account_id/subscriptions":
    resource: "subscription_collection"
    actions:
      create:
        method: "POST"
        authorization: "Capability"
        request_entity: "subscription"
        response_entity: "subscription"

  "/accounts/:account_id/subscriptions/:sub_id":
    resource: "subscription"
    actions:
      events:
        method: "GET"
        authorization: "Capability"
        response_entity: "events"



