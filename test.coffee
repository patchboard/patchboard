fs = require("fs")
Rigger = require("./coffeescript/rigger")

string = fs.readFileSync("examples/messaging/interface.json")
full_interface = JSON.parse(string)
interface = {}
for pattern, rig of full_interface
  resource = rig.resource
  delete rig.resource
  interface[resource] = rig

string = fs.readFileSync("examples/messaging/resource_schema.json")
schema = JSON.parse(string)




rigger = new Rigger.Client "http://localhost:1337",
  interface: interface
  schema: schema

create_channel = (collection, name, callback) ->
  collection.create
    name: name
    callback: callback

get_channels = (rigger, properties) ->
  collection = new rigger.resources.channel_collection(properties)
  collection.create
    name: "monkey"
    callback: (data) ->
      collection.all callback: (data) ->
        console.log(data)


account_collection = new rigger.resources.account_collection
  url: "http://localhost:1337/accounts"

account_collection.create
  email: "foo#{Math.random()}@bar.com", password: "monkeyshines",
  callback: (data) ->
    collection = new rigger.resources.channel_collection(data.resources.channels)
    create_channel collection, "monkey", (data) ->
      collection.all callback: (data) ->
        console.log(data)

