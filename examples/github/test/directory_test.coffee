GitHubClient = require("../client")
Testify = require("testify")
assert = require "assert"

fs = require("fs")
# read login:password from a file
string = fs.readFileSync("auth")
string = string.slice(0, string.length-1)
basic_auth = new Buffer(string).toString("base64")

client = new GitHubClient(basic_auth)

Testify.test "Resources from the directory", (context) ->
  repositories = client.directory.repositories

  context.test "self", (context) ->
    client.directory.authenticated_user.get
      on:
        response: (response) ->
          context.fail "Unexpected response status: #{response.status}"
        200: (response, user) ->
          context.test "response is a resource", ->
            assert.equal user.resource_type, "user"

  context.test "Own repositories", (context) ->
    repositories.list
      on:
        response: (response) ->
          context.fail "Unexpected response status: #{response.status}"
        200: (response, list) ->
          context.test "response is an array", (context) ->
            assert.equal list.constructor, Array
            context.test "items are all repositories", ->
              for item in list
                assert.equal item.resource_type, "repository"

  context.test "Own orgs", (context) ->
    client.directory.organizations.list
      on:
        response: (response) ->
          context.fail "Unexpected response status: #{response.status}"
        200: (response, list) ->
          context.test "response is an array", (context) ->
            assert.equal list.constructor, Array
            context.test "items are all organizations", ->
              for item in list
                assert.equal item.resource_type, "organization"


