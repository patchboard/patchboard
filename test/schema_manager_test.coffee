assert = require("assert")

helpers = require("./helpers")
test = helpers.test

SchemaManager = require("../coffeescript/service/schema_manager")

#fs = require("fs")
#string = fs.readFileSync("examples/spire/resource_schema.json")
#schemas = JSON.parse(string)


schema =
  id: "spire"
  properties:
    capability:
      id: "capability"
      type: "string"

    capability_dictionary:
      id: "capability_dictionary"
      type: "object"
      additionalProperties: {$ref: "capability"}

    resource:
      id: "resource"
      type: "object"
      properties:
        url: {type: "string", readonly: true}
        capabilities: {$ref: "capability_dictionary"}

    account:
      id: "account"
      extends: {$ref: "resource"}
      properties:
        id: {type: "string", readonly: true}
        secret: {type: "string", readonly: true}
        created_at: {type: "number", readonly: true}
        email: {type: "string", required: true}
        password: {type: "string", required: true}
        name: {type: "string"}

jsv = JSV.createEnvironment()

data =
  account:
    url: "foo"
    email: "me@me.com"
    password: "strongpassword"
    capabilities:
      get: "foo"
      update: "bar"

test "transform of schema for validation with JSV", ->
  result = jsv.validate(data, schema)
  assert.deepEqual result.errors, []



