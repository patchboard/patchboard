colors = require "colors"
assert = require "assert"

helpers = require("../../test/helpers")
test = helpers.test

Patchboard = require("../../src/patchboard")

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



client_interface = require("./interface")
schema = require("./resource_schema")
map = require("./map")

module.exports =
  test: helpers.test
  partial_equal: helpers.partial_equal
  Patchboard: Patchboard
  patchboard: helpers.patchboard
  spire: spire_tests
  interface: client_interface
  schema: schema
  map: map
