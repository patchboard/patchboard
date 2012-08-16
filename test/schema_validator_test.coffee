assert = require("assert")

helpers = require("./helpers")
testify = require("../src/testify")
util = require("util")

Patchboard = require("../src/patchboard")
api = require("./sample_api.coffee")
service = new Patchboard.Service(api)
manager = service.schema_manager
validator = service.validator



testify "schema name resolution", ->
  assert.ok validator.get_schema("api#attachment")


# special helper for JSV validation results
assert_no_errors = (errors) ->
  if errors.length > 0
    console.log(errors)
    assert.equal(errors.length, 0)

testify "pass for minimal correct data", ->
  result = validator.validate "api#resource_instance",
    url: "http://monkey.com/blah"
    expected: "you got it"
  assert_no_errors(result.errors)

testify "fail for unexpected properties", ->
  result = validator.validate "api#resource_instance",
    url: "http://monkey.com/blah"
    expected: "you got it"
    unexpected: "now, we can't have this sort of thing"
  assert.equal(result.errors.length, 1)
  error = result.errors[0]
  assert.equal(error.attribute, "additionalProperties")
  assert.equal(error.schemaUri, "urn:api#resource_instance")



