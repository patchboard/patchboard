assert = require("assert")

helpers = require("./helpers")
test = helpers.test
#interface_spec = helpers.interface
#schema = helpers.schema

Rigger = require("../coffeescript/rigger")

dispatcher = new Rigger.Dispatcher
  interface: helpers.interface
  schema: helpers.schema
  map: helpers.map

media_type = (type) ->
  "application/vnd.spire-io.#{type}+json;version=1.0"

class MockRequest

  constructor: (options) ->
    @url = options.url
    @method = options.method
    @headers = options.headers

test_dispatch = (resource, action, options) ->
  request = new MockRequest(options)
  result = dispatcher.dispatch(request)
  test "Dispatching for #{resource}, #{action}", ->
    assert.equal(result.resource_type, resource)
    assert.equal(result.action_name, action)

test_dispatch "account_collection", "create",
  url: "http://host/accounts"
  method: "POST"
  headers:
    "Content-Type": media_type("account")
    "Accept": media_type("session")

test_dispatch "account", "get",
  url: "http://localhost:1337/account/12345"
  method: "GET"
  headers:
    "Accept": media_type("account")
    "Authorization": "Capability <token>"

test_dispatch "channel_collection", "create",
  url: "http://host/account/12345/channels"
  method: "POST"
  headers:
    "Content-Type": media_type("channel")
    "Accept": media_type("channel")
    "Authorization": "Capability <token>"

test_dispatch "channel_collection", "get_by_name",
  url: "http://localhost:1337/account/12345/channels?name=smurf"
  method: "GET"
  headers:
    "Accept": media_type("channels")
    "Authorization": "Capability <token>"


