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


account_collection = new rigger.resources.account_collection
  url: "http://localhost:1337/accounts"

account_collection.create
  email: "foo#{Math.random()}@bar.com", password: "monkeyshines",
  callback: (session) ->
    collection = new rigger.resources.channel_collection(session.resources.channels)
    collection.create
      name: "monkey"
      callback: (channel) ->
        collection.all
          callback: (channel_dict) ->
            #console.log("channel:", channel_dict)

