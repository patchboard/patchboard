assert = require "assert"

test = (name, fn) ->
  try
    fn()
    console.log("Pass: '#{name}'")
  catch error
    if error.name == "AssertionError"
      console.log("Fail: '#{name}':", error)
      console.log(error.stack)
    else
      console.log("Error: '#{name}':", error)
      console.log(error.stack)
    process.exit()

partial_equal = (actual, expected) ->
  for key, val of expected
    assert.deepEqual(actual[key], val)

validate =
  session: (session) ->
    test "Session is wrapped", ->
      assert.equal(session.constructor.resource_type, "session")

  channel_collection: (channel_collection) ->
    test "Channel collection is wrapped", ->
      assert.equal(
        channel_collection.constructor.resource_type,
        "channel_collection"
      )
      assert(channel_collection.url)
      assert(channel_collection.capabilities.create)

  channel: (channel) ->
    test "Channel is wrapped", ->
      assert.equal(channel.constructor.resource_type, "channel")
    test "Channel has correct getters", ->
      assert.equal(channel.name.constructor, String)
      assert.equal(channel.application_key.constructor, String)
      assert.equal(channel.limit.constructor, Number)


module.exports =
  test: test
  partial_equal: partial_equal
  validate: validate
  interface: require("../api/interface")
  schema: require("../api/schema")
  map: require("../api/map")
