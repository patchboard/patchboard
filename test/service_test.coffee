assert = require("assert")
Testify = require "testify"

{api} = require "./helpers"
Service = require "../src/server/service"
{parse_url} = require "../src/server/util"
service = new Service(api, url: "http://gh-knockoff.com/")


Testify.test "Patchboard.Service", (context) ->

  context.test "URL generation with no arguments", ->
    assert.equal(
      service.generate_url("repositories"),
      "http://gh-knockoff.com/repos"
    )

  context.test "URL generation with named arguments", ->
    assert.equal(
      service.generate_url("user", {login: "mylogin"}),
      "http://gh-knockoff.com/user/mylogin"
    )

  context.test "URL generation with positional arguments", ->
    assert.equal(
      service.generate_url("user", "mylogin"),
      "http://gh-knockoff.com/user/mylogin"
    )

  context.test "URL normalization", ->
    parsed = parse_url("http://gh-knockoff.com//some/path")
    assert.equal(parsed.path, "/some/path")

  # TODO: test failure conditions (too many or few arguments, incorrect names, etc.)

