assert = require("assert")

helpers = require("./helpers")
test = helpers.test
util = require("util")


fs = require("fs")
string = fs.readFileSync("examples/spire/resource_schema.json")
schemas = JSON.parse(string)


app_schema =
  id: "spire"
  properties:
    resource:
      id: "#resource"
      extends: {$ref: "patchboard#resource"}
      properties:
        capabilities:
          $ref: "spire#capability_dictionary"

    account:
      id: "#account"
      extends: {$ref: "spire#resource"}
      properties:
        id: {type: "string", readonly: true}
        secret: {type: "string", readonly: true}
        created_at: {type: "number", readonly: true}
        email: {type: "string", required: true}
        password: {type: "string", required: true}
        name: {type: "string"}

    capability:
      id: "#capability"
      type: "string"

    capability_dictionary:
      id: "#capability_dictionary"
      type: "object"
      additionalProperties: {$ref: "spire#capability"}


#t = {}
#t.id = "spire"
#t.properties = {}

#for name, schema of schemas
  #trans = { id: "##{name}"}
  #if schema.type == "resource"
    #delete schema.type
    #trans.extends = {$ref: "patchboard#resource"}
  #delete schema.media_type
  #required = schema.required
  #delete schema.required
  #for key, value of schema
    #trans[key] = value
  #if required
    #for key in required
      #trans.properties[key].required = true
  #t.properties[name] = trans

#console.log(JSON.stringify(t.properties.account, null, 2))

#assert.deepEqual(t.properties.account.properties, app_schema.properties.account.properties)

#process.exit()


SchemaManager = require("../src/service/schema_manager")
sm = new SchemaManager(app_schema)


assert_no_errors = (errors) ->
  if errors.length > 0
    console.log(errors)
    assert.equal(errors.length, 0)

test "pass for minimal correct data", ->
  result = sm.validate "account",
    url: "foo"
    email: "me@me.com"
    password: "strongpassword"
    capabilities:
      get: "foo"
      update: "bar"
  assert_no_errors(result.errors)


test "fail when capability is not a string", ->
  result = sm.validate "account",
    url: "foo"
    email: "me@me.com"
    password: "strongpassword"
    capabilities:
      get: 3
      update: "bar"
  assert.equal(result.errors.length, 1)
  helpers.partial_equal result.errors[0],
    schemaUri: "urn:spire#capability"
    attribute: "type"

test "fail when email is missing", ->
  result = sm.validate "account",
    url: "foo"
    password: "strongpassword"
    capabilities:
      get: "foo"
      update: "bar"
  assert.equal(result.errors.length, 1)
  helpers.partial_equal result.errors[0],
    schemaUri: "urn:spire#account/properties/email"
    attribute: "required"
