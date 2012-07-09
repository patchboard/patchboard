assert = require("assert")

test = require("./test/helpers").test

fs = require("fs")
Rigger = require("./coffeescript/rigger")

# read the full interface (intended for use by the server side)
# and create the filtered interface for use by clients.
# In real use, the client will discover the interface and schema
# via a request to the server.
string = fs.readFileSync("examples/spire/interface.json")
full_interface = JSON.parse(string)
client_interface = {}
for pattern, rig of full_interface
  resource = rig.resource
  delete rig.resource
  client_interface[resource] = rig

string = fs.readFileSync("examples/spire/resource_schema.json")
schema = JSON.parse(string)

validate_session = (session) ->
  test "Session is wrapped", ->
    assert.equal(session.constructor.resource_type, "session")

validate_channel_collection = (channel_collection) ->
  test "Channel collection is wrapped", ->
    assert.equal(
      channel_collection.constructor.resource_type,
      "channel_collection"
    )
    assert(channel_collection.url)
    assert(channel_collection.capabilities.create)

validate_channel = (channel) ->
  test "Channel is wrapped", ->
    assert.equal(channel.constructor.resource_type, "channel")
  test "Channel has correct getters", ->
    assert.equal(channel.name.constructor, String)
    assert.equal(channel.application_key.constructor, String)
    assert.equal(channel.limit.constructor, Number)

validate_dictionary = (dictionary, type) ->
  test "Dictionary contains items of type #{type}", ->
    for name in Object.keys(dictionary)
      assert.equal(dictionary[name].constructor.resource_type, type)

rigger = new Rigger.Client "http://localhost:1337",
  interface: client_interface
  schema: schema

# Fake out the discovery of public resources
account_collection = new rigger.wrappers.account_collection
  url: "http://localhost:1337/accounts"

account_collection.create
  email: "foo#{Math.random()}@bar.com", password: "monkeyshines",
  callback: (session) ->
    validate_session(session)

    channel_collection = session.resources.channels
    validate_channel_collection(channel_collection)

    channel_collection.create
      name: "monkey"
      callback: (channel) ->
        validate_channel(channel)
        channel_collection.all
          callback: (channel_dict) ->
            validate_dictionary(channel_dict, "channel")
            channel_dict.monkey.publish
              content: "bologna"
              callback: (message) ->
                test "Message is wrapped", ->
                  assert.equal(message.constructor.resource_type, "message")
            

