module.exports =
  id: "spire.io"
  properties:

    capability:
      #id: "#capability"
      type: "string"

    capability_dictionary:
      #id: "#capability_dictionary"
      type: "object"
      additionalProperties: {$ref: "spire#capability"}

    resource:
      #id: "#resource"
      extends: {$ref: "patchboard#resource"}
      properties:
        capabilities:
          $ref: "spire#capability_dictionary"

    account:
      #id: "#account"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.account+json;version=1.0"
      properties:
        id:
          type: "string"
          readonly: true
        secret:
          type: "string"
          readonly: true
        created_at:
          type: "number"
          readonly: true
        email:
          type: "string"
          required: true
        password:
          type: "string"
          required: true
        name: {type: "string"}

    account_collection:
      extends: {$ref: "#resource"}
      #mediaType: "application/vnd.spire-io.accounts+json;version=1.0"

    session:
      #id: "#session"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.session+json;version=1.0"
      properties:
        resources:
          type: "object"
          properties:
            account: {$ref: "#account"}
            channels: {$ref: "#channel_collection"}
            subscriptions: {$ref: "#subscription_collection"}
            applications: {type: "object"}
            notifications: {type: "object"}
            
    session_collection:
      #id: "#session_collection"
      extends: {$ref: "#resource"}

    channel:
      #id: "#channel"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.channel+json;version=1.0"
      properties:
        name:
          type: "string"
          required: true
        application_key:
          type: "string"
          readonly: true
        limit: {type: "number"}
      required: ["name"]

    channel_collection:
      #id: "#channel_collection"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.channels+json;version=1.0"

    channel_dictionary:
      type: "object"
      mediaType: "application/vnd.spire-io.channels+json;version=1.0"
      additionalProperties: {$ref: "#channel"}

    subscription:
      #id: "#subscription"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.subscription+json;version=1.0"
      properties:
        application_key:
          type: "string"
          readonly: true
        name: {type: "string"}
        channels:
          type: "array"
          items: {"type": "string"}

    subscription_collection:
      #id: "#subscription_collection"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.subscriptions+json;version=1.0"

    subscription_dictionary:
      #id: "#subscription_dictionary"
      type: "object"
      mediaType: "application/vnd.spire-io.subscriptions+json;version=1.0"
      additionalProperties: {$ref: "subscription"}

    event:
      #id: "#event"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.event+json;version=1.0"
      properties:
        channel_name: {type: "string"}
        content: {type: "object"}
        timestamp: {type: "number"}
        reason: {type: "string"}

    event_list:
      #id: "#event_list"
      type: "object"
      mediaType: "application/vnd.spire-io.events+json;version=1.0"
      properties:
        first: {type: "number"}
        last: {type: "number"}
        messages: {$ref: "#message_list"}
        joins: {}
        parts: {}

    message:
      #id: "#message"
      extends: {$ref: "#resource"}
      mediaType: "application/vnd.spire-io.message+json;version=1.0"
      properties:
        channel_name: {type: "string"}
        content: {type: "object"}
        timestamp: {type: "number"}

    message_list:
      #id: "#message_list"
      type: "array"
      items: {$ref: "#message"}

