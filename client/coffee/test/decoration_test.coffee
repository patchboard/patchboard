Client = require "../client"
Testify = require "testify"
assert = require "assert"
api = require "./test_api"

client = new Client(api)

Testify.test "Resource decoration", (context) ->

  schema = client.schema_manager.find "urn:json:test#dwarf"
  object = client.decorate schema,
    name: "Gimli"
    url: "http://somewhere.com/"
    tools: [
      {name: "hammer"},
      {name: "axe"}
    ]

  context.test "Top level object", (context) ->
    context.test "is a resource", ->
      assert.ok object.constructor != Object
    context.test "has expected action methods", ->
      assert.equal typeof(object.get), "function"

  context.test "Objects in array", (context) ->
    context.test "are resources", ->
      for tool in object.tools
        assert.ok tool.constructor != Object
    context.test "have expected action methods", ->
      for tool in object.tools
        assert.equal typeof(tool.use), "function"
        assert.equal typeof(tool.discard), "function"
