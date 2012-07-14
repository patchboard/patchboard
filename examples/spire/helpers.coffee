colors = require "colors"
assert = require "assert"

helpers = require("../../test/helpers")
test = helpers.test

spire_tests =
  validate_session: (session) ->
    test "Session is wrapped", ->
      assert.equal(session.constructor.resource_type, "session")

  validate_channel_collection: (channel_collection) ->
    test "Channel collection is wrapped", ->
      assert.equal(
        channel_collection.constructor.resource_type,
        "channel_collection"
      )
      assert(channel_collection.url)
      assert(channel_collection.capabilities.create)

  validate_channel: (channel) ->
    test "Channel is wrapped", ->
      assert.equal(channel.constructor.resource_type, "channel")
    test "Channel has correct getters", ->
      assert.equal(channel.name.constructor, String)
      assert.equal(channel.application_key.constructor, String)
      assert.equal(channel.limit.constructor, Number)


fs = require("fs")
Rigger = require("../../coffeescript/rigger")

string = fs.readFileSync("./interface.json")
client_interface = JSON.parse(string)

string = fs.readFileSync("./resource_schema.json")
schema = JSON.parse(string)

string = fs.readFileSync("./map.json")
map = JSON.parse(string)

module.exports =
  test: helpers.test
  partial_equal: helpers.partial_equal
  Rigger: Rigger
  rigger: helpers.rigger
  spire: spire_tests
  interface: client_interface
  schema: schema
  map: map
