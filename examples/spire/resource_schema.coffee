module.exports =
  resource:
    type: "object"
    properties:
      url: {type: "string"}
      capabilities: {type: "object"}
    required: ["url"]

  account:
    type: "resource"
    media_type: "application/vnd.spire-io.account+json;version=1.0"
    properties:
      id: {type: "string", readonly: true}
      secret: {type: "string", readonly: true}
      created_at: {type: "number"}
      email: {type: "string"}
      name: {type: "string"}
      password: {type: "string"}
    required: ["email", "password"]

  account_collection:
    type: "array"
    media_type: "application/vnd.spire-io.accounts+json;version=1.0"
    items:
      type: "account"

  session:
    type: "object"
    media_type: "application/vnd.spire-io.session+json;version=1.0"
    properties:
      url: {type: "string"}
      capabilities: {type: "capability_collection"}
      resources:
        type: "dictionary"
        additionalProperties:
          type: "resource"

  channel:
    type: "resource"
    media_type: "application/vnd.spire-io.channel+json;version=1.0"
    properties:
      name: {type: "string"}
      application_key: {type: "string", readonly: true}
      limit: {type: "number"}
    required: ["name"]

  channel_collection:
    type: "object"
    media_type: "application/vnd.spire-io.channels+json;version=1.0"
    properties:
      url: {type: "string"}
      capabilities: {type: "capability_collection"}

  channel_dictionary:
    type: "dictionary"
    media_type: "application/vnd.spire-io.channels+json;version=1.0"
    items: {type: "channel"}

  capability_collection:
    type: "dictionary"
    items: {type: "string"}


