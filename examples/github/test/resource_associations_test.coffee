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

  client.resources.repository(login: "automatthew", name: "fate").get
    on:
      response: (response) ->
        context.fail "unexpected response status: #{response.status}"
      200: (response, repo) ->
        console.log "X-Ratelimit-Remaining:", response.headers["X-Ratelimit-Remaining"]
        context.test "repository.contributors", (context) ->
          repo.contributors.list
            on:
              response: (response) ->
                context.fail "unexpected response status: #{response.status}"
              200: (response, contributors) ->
                context.test "result is a non-empty array", ->
                  assert.equal contributors.constructor, Array
                  assert.ok contributors.length > 0
                context.test "each item is an User resource", ->
                  for item in contributors
                    assert.equal item.resource_type, "user"

        context.test "repository.languages", (context) ->
          repo.languages.list
            on:
              response: (response) ->
                context.fail "unexpected response status: #{response.status}"
              200: (response, languages) ->
                context.test "result is an object", ->
                  assert.equal languages.constructor, Object


