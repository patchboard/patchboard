module.exports =
  resource:
    type: "object"
    properties:
      url: {type: "string"}
      capabilities: {type: "object"}
    required: ["url"]

  account_collection:
    type: "array"
    media_type: "application/vnd.spire-io.accounts+json;version=1.0"
    items:
      type: "account"

  account:
    extends: ["resource"]
    media_type: "application/vnd.spire-io.account+json;version=1.0"
    properties:
      id:
        type: "string"
        readonly: true
      created_at: {type: "number"}
      secret:
        type: "string"
        readonly: true
      email:
        type: "string"
      name:
        type: "string"
      password:
        type: "string"
    required: ["email", "password"]

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

  channel_collection:
    type: "object"
    media_type: "application/vnd.spire-io.channels+json;version=1.0"
    properties:
      url: {type: "string"}
      capabilities: {type: "capability_collection"}

  channel:
    extends: ["resource"]
    media_type: "application/vnd.spire-io.channel+json;version=1.0"
    properties:
      name: {type: "string"}
      limit: {type: "number"}
    required: ["name"]

  capability_collection:
    type: "dictionary"
