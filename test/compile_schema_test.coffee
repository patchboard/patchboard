assert = require("assert")

helpers = require("./helpers")
test = helpers.test

patchboard_schemas =
  account:
    extends: "resource"
    media_type: "patchboard.account"
    properties:
      id: {type: "string", readonly: true}
      secret: {type: "string", readonly: true}
      created_at: {type: "number", readonly: true}
      email: {type: "string"}
      name: {type: "string"}
      password: {type: "string"}
    required: ["email", "password"]

  account_collection:
    extends: "resource"
    media_type: "patchboard.accounts"

  session:
    extends: "resource"
    media_type: "patchboard.session"
    properties:
      resources:
        type: "object"
        properties:
          account: {type: "account"}
          channels: {type: "channel_collection"}
          applications: {type: "object"}
          subscriptions: {type: "subscription_collection"}
          notifications: {type: "object"}


correct_schema =
  id: "api"
  properties:

    capability:
      id: "#capability"
      type: "string"

    capability_dictionary:
      id: "#capability_dictionary"
      type: "object"
      additionalProperties: {$ref: "api#capability"}

    resource:
      id: "#resource"
      extends: {$ref: "rigger#resource"}
      properties:
        capabilities:
          $ref: "api#capability_dictionary"

    account:
      id: "#account"
      mediaType: "patchboard.account"
      extends: {$ref: "api#resource"}
      properties:
        id: {type: "string", readonly: true}
        secret: {type: "string", readonly: true}
        created_at: {type: "number", readonly: true}
        email: {type: "string", required: true}
        password: {type: "string", required: true}
        name: {type: "string"}

    session:
      id: "#session"
      mediaType: "patchboard.session"
      extends: {$ref: "api#resource"}
      properties:
        resources:
          type: "object"
          properties:
            account: {$ref: "api#account"}
            channels: {$ref: "api#channel_collection"}
            applications: {type: "object"}
            subscriptions: {$ref: "api#subscription_collection"}
            notifications: {type: "object"}



SchemaManager = require("../src/service/schema_manager")
transformed = SchemaManager.transform_schemas(patchboard_schemas)

test "One layer schema transformed", ->
  #console.log(JSON.stringify(transformed.properties.account, null, 2))
  assert.deepEqual(transformed.properties.account, correct_schema.properties.account)

test "Deeply nested schema transformed", ->
  #console.log(JSON.stringify(transformed.properties.session, null, 2))
  #console.log(JSON.stringify(correct_schema.properties.session, null, 2))
  assert.deepEqual(
    transformed.properties.session,
    correct_schema.properties.session
  )



