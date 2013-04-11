GitHubClient = require("../client")
Testify = require("testify")
assert = require "assert"

fs = require("fs")
# read login:password from a file
string = fs.readFileSync("auth")
string = string.slice(0, string.length-1)
basic_auth = new Buffer(string).toString("base64")

client = new GitHubClient(basic_auth)


Testify.test "Resource associations", (context) ->

  context.test "user repositories", (context) ->
    client.resources.user(login: "dyoder").repositories.list
      on:
        request_error: (error) ->
          context.fail(error)
        response: (response) ->
          context.fail "unexpected response status: #{response.status}"
        200: (response, list) ->
          context.test "result is a non-empty array", ->
            assert.equal list.constructor, Array
            assert.ok list.length > 0
          context.test "each item is a Repository resource", ->
            for item in list
              assert.equal item.resource_type, "repository"


  context.test "repository associations", (context) ->
    repo = client.resources.repository(login: "automatthew", name: "fate")

    context.test "repository associations", (context) ->
      repo.contributors.list
        on:
          request_error: (error) -> context.fail(error)
          response: (response) ->
            context.fail "unexpected response status: #{response.status}"
          200: (response, contributors) ->
            context.test "result is a non-empty array", ->
              assert.equal contributors.constructor, Array
              assert.ok contributors.length > 0
            context.test "each item is a User resource", ->
              for item in contributors
                assert.equal item.resource_type, "user"

    context.test "repository.languages", (context) ->
      repo.languages.list
        on:
          request_error: (error) -> context.fail(error)
          response: (response) ->
            context.fail "unexpected response status: #{response.status}"
          200: (response, languages) ->
            context.test "result is an dictionary containing numbers", ->
              assert.equal languages.constructor, Object
              for name, lines of languages
                assert.equal name.constructor, String
                assert.equal lines.constructor, Number


