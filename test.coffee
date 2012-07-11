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

expected_response = (status, callback) ->
  callbacks =
    response: (response) ->
      throw "unexpected response status: #{response.status}"
    error: (response) ->
      throw "Error: #{response.status}"

  callbacks[status] = callback
  callbacks

# Spire api tests
test_channels = (channel_collection) ->
  channel_collection.create
    content:
      name: "monkey"
    on:
      expected_response 201,
        (response, channel) ->
          helpers.spire.validate_channel(channel)
          list_channels(channel_collection)


list_channels = (channel_collection) ->
  channel_collection.all
    on:
      expected_response 200,
        (response, channel_dict) ->
          helpers.rigger.validate_dictionary(channel_dict, "channel")
          publish_to_channel(channel_dict.monkey)

publish_to_channel = (channel) ->
  channel.publish
    content:
      content: "bologna"
    on:
      expected_response 201,
        (response, message) ->
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
  on:
    201: (response, session) ->
      helpers.spire.validate_session(session)
      channel_collection = session.resources.channels
      helpers.spire.validate_channel_collection(channel_collection)
      test_channels(channel_collection)
    response: (response) ->
      throw "unexpected response status: #{response.status}"
    error: (response) ->
      throw "Error: #{response.status}"


