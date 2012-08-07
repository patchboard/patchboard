assert = require("assert")

helpers = require("./helpers")
testify = require("../src/testify")
util = require("util")


#fs = require("fs")
#string = fs.readFileSync("examples/spire/resource_schema.json")
#schemas = JSON.parse(string)


app_schema =
  id: "spire"
  properties:

    capability:
      type: "string"

    capability_dictionary:
      type: "object"
      additionalProperties: {$ref: "spire#capability"}

    resource:
      extends: {$ref: "patchboard#resource"}
      properties:
        capabilities:
          $ref: "spire#capability_dictionary"

    account:
      mediaType: "application/vnd.spire-io.account+json;version=1.0"
      extends: {$ref: "spire#resource"}
      properties:
        id: {type: "string", readonly: true}
        secret: {type: "string", readonly: true}
        created_at: {type: "number", readonly: true}
        email: {type: "string", required: true}
        password: {type: "string", required: true}
        name: {type: "string"}





SchemaManager = require("../src/service/schema_manager")
sm = new SchemaManager(app_schema)

console.log sm.document()

testify "schema name resolution", ->
  assert.ok sm.get_schema("#account")
  assert.ok sm.get_schema("spire#account")
  assert.ok sm.get_schema("patchboard#resource")


#assert_no_errors = (errors) ->
  #if errors.length > 0
    #console.log(errors)
    #assert.equal(errors.length, 0)

#testify "pass for minimal correct data", ->
  #result = sm.validate "#account",
    #url: "foo"
    #email: "me@me.com"
    #password: "strongpassword"
    #capabilities:
      #get: "foo"
      #update: "bar"
  #assert_no_errors(result.errors)


#testify "fail when capability is not a string", (test) ->
  #result = sm.validate "#account",
    #url: "foo"
    #email: "me@me.com"
    #password: "strongpassword"
    #capabilities:
      #get: 3
      #update: "bar"
  #assert.equal(result.errors.length, 1)
  #helpers.partial_equal result.errors[0],
    #schemaUri: "urn:spire#capability"
    #attribute: "type"
  #test.done()

#testify "fail when email is missing", (test) ->
  #result = sm.validate "#account",
    #url: "foo"
    #password: "strongpassword"
    #capabilities:
      #get: "foo"
      #update: "bar"
  #assert.equal(result.errors.length, 1)
  #helpers.partial_equal result.errors[0],
    #schemaUri: "urn:spire#account/properties/email"
    #attribute: "required"
  #test.done()

