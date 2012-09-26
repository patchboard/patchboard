assert = require("assert")

helpers = require("./helpers")
testify = require("../src/testify")

api = require("./sample_api.coffee")
Patchboard = require("../patchboard")
service = new Patchboard.Service(api)


testify "URL generation with no arguments", ->
  assert.equal(
    service.generate_url("resource_collection"),
    "http://patchboarded.com/resources"
  )

testify "URL generation with named arguments", ->
  assert.equal(
    service.generate_url("resource_instance", {id: "someidvalue"}),
    "http://patchboarded.com/resources/someidvalue"
  )
  assert.equal(
    service.generate_url("attachment", {id: "someidvalue", attachment_id: "othervalue"}),
    "http://patchboarded.com/resources/someidvalue/attachments/othervalue"
  )

testify "URL generation with positional arguments", ->
  assert.equal(
    service.generate_url("resource_instance", "someidvalue"),
    "http://patchboarded.com/resources/someidvalue"
  )

  assert.equal(
    service.generate_url("attachment", "someidvalue", "othervalue"),
    "http://patchboarded.com/resources/someidvalue/attachments/othervalue"
  )

api.service_url = "http://patchboarded.com/"
service = new Patchboard.Service(api)

testify "URL generation with no arguments", ->
  assert.equal(
    service.generate_url("resource_collection"),
    "http://patchboarded.com/resources"
  )

testify "URL normalization", ->
  parsed = service.parse_url("http://patchboarded.com//some/path")
  assert.equal(parsed.path, "/some/path")

# TODO: test failure conditions (too many or few arguments, incorrect names, etc.)
