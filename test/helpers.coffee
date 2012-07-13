colors = require "colors"
assert = require "assert"

test = (name, fn) ->
  try
    fn()
    console.log colors.green("Pass: '#{name}'")
  catch error
    if error.name == "AssertionError"
      console.log colors.red("Fail: '#{name}':"), colors.red(error)
      console.log colors.white(error.stack)
    else
      console.log colors.yellow("Error: '#{name}':"), colors.yellow(error)
      console.log colors.white(error.stack)
    process.exit()

partial_equal = (actual, expected) ->
  for key, val of expected
    assert.deepEqual(actual[key], val)

rigger =
  validate_dictionary: (dictionary, type) ->
    test "Dictionary contains items of type #{type}", ->
      for name in Object.keys(dictionary)
        assert.equal(dictionary[name].constructor.resource_type, type)

spire =
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
Rigger = require("../coffeescript/rigger")

string = fs.readFileSync("examples/spire/interface.json")
client_interface = JSON.parse(string)

string = fs.readFileSync("examples/spire/resource_schema.json")
schema = JSON.parse(string)


string = fs.readFileSync("examples/spire/map.json")
map = JSON.parse(string)

module.exports =
  test: test
  spire: spire
  rigger: rigger
  interface: client_interface
  schema: schema
  map: map
