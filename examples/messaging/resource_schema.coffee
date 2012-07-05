module.exports =
  account_collection:
    type: "array"
    items:
      type: "account"

  account:
    type: "object"
    properties:
      id:
        type: "string"
        readonly: true
      secret:
        type: "string"
        readonly: true
      email:
        type: "string"
      name:
        type: "string"
      password:
        type: "string"
    required: ["email"]

  channel_collection:
    type: "array"
    items:
      type: "channel"

  channel:
    type: "object"
    properties:
      name:
        type: "string"
    required: ["name"]

