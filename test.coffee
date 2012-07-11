assert = require("assert")

helpers = require("./test/helpers")
test = helpers.test

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

# Spire api tests
test_channels = (channel_collection) ->
  channel_collection.create
    content:
      name: "monkey"
    callback: (channel) ->
      helpers.spire.validate_channel(channel)
      channel_collection.all
        callback: (channel_dict) ->
          helpers.rigger.validate_dictionary(channel_dict, "channel")
          channel_dict.monkey.publish
            content:
              content: "bologna"
            callback: (message) ->
              test "Message is wrapped", ->
                assert.equal(message.constructor.resource_type, "message")


# Set up the Rigger client
client = new Rigger.Client "http://localhost:1337",
  interface: client_interface
  schema: schema

# Fake out the discovery of public resources
account_collection = new client.wrappers.account_collection
  url: "http://localhost:1337/accounts"

# run actual tests
account_collection.create
  content:
    email: "foo#{Math.random()}@bar.com", password: "monkeyshines",
  callback: (session) ->
    helpers.spire.validate_session(session)

    channel_collection = session.resources.channels
    helpers.spire.validate_channel_collection(channel_collection)

    test_channels(channel_collection)


