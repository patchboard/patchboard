assert = require("assert")
Testify = require "testify"

api = require("./sample_api.coffee")
Patchboard = require("../patchboard")
service = new Patchboard.Service(api)


Testify.test "Patchboard.Service", (context) ->

  context.test "URL generation with no arguments", ->
    assert.equal(
      service.generate_url("organizations"),
      "http://gh-knockoff.com/organizations"
    )

  context.test "URL generation with named arguments", ->
    assert.equal(
      service.generate_url("organization", {id: "someidvalue"}),
      "http://gh-knockoff.com/organizations/someidvalue"
    )

  context.test "URL generation with positional arguments", ->
    assert.equal(
      service.generate_url("organization", "someidvalue"),
      "http://gh-knockoff.com/organizations/someidvalue"
    )

  context.test "URL normalization", ->
    parsed = service.parse_url("http://gh-knockoff.com//some/path")
    assert.equal(parsed.path, "/some/path")

  # TODO: test failure conditions (too many or few arguments, incorrect names, etc.)
