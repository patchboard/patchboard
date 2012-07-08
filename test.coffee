assert = require("assert")

test = require("./test/helpers").test


fs = require("fs")
Rigger = require("./coffeescript/rigger")

string = fs.readFileSync("examples/spire/interface.json")
full_interface = JSON.parse(string)
interface = {}
for pattern, rig of full_interface
  resource = rig.resource
  delete rig.resource
  interface[resource] = rig

string = fs.readFileSync("examples/spire/resource_schema.json")
schema = JSON.parse(string)



rigger = new Rigger.Client "http://localhost:1337",
  interface: interface
  schema: schema

#test "Defines expected resource classes", ->
  #assert.deepEqual Object.keys(rigger.resources).sort(),
    #["account", "account_collection", "session", "channel",
    #"channel_collection"].sort()

account_collection = new rigger.resources.account_collection
  url: "http://localhost:1337/accounts"

console.log(account_collection.url)

account_collection.create
  email: "foo#{Math.random()}@bar.com", password: "monkeyshines",
  callback: (session) ->
    test "Session is wrapped", ->
      assert.equal(session.constructor.resource_name, "session")

    channel_collection = session.resources.channels
    test "Channel collection has the correct constructor", ->
      assert.equal(
        channel_collection.constructor.resource_name,
        "channel_collection"
      )
    channel_collection.create
      name: "monkey"
      callback: (channel) ->

        test "Channel has correct constructor", ->
          assert.equal(channel.constructor.resource_name, "channel")

        channel_collection.all
          callback: (channel_dict) ->
            test "Channel dictionary items are wrapped", ->
              assert.equal(
                channel_dict.monkey.constructor.resource_name, "channel"
              )
              assert.equal(channel_dict.monkey.name, "monkey")
            channel_dict.monkey.publish
              content: "bologna"
              callback: (message) ->
                test "Message is wrapped", ->
                  assert.equal(message.constructor.resource_name, "message")
            

