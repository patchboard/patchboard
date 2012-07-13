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



test "unpacking path patterns", ->
  assert.deepEqual(
    dispatcher.unpack_url_pattern("/accounts/:account_id"),
    ["accounts", {name: "account_id"}]
  )
  assert.deepEqual(
    dispatcher.unpack_url_pattern("/accounts/:account_id/channels"),
    ["accounts", {name: "account_id"}, "channels"]
  )

  assert.deepEqual(
    dispatcher.unpack_url_pattern("/accounts/:account_id/channels/:channel_id"),
    ["accounts", {name: "account_id"}, "channels", {name: "channel_id"}]
  )

test "Matching path patterns", ->
  result = dispatcher.match_path(
    "/accounts/54321",
    ["accounts", {name: "account_id"}]
  )
  assert.deepEqual(
    result,
    {account_id: "54321"}
  )

  result = dispatcher.match_path(
    "/accounts/54321/channels/abcdefg",
    ["accounts", {name: "account_id"}, "channels", {name: "channel_id"}]
  )
  assert.deepEqual(
    result,
    {account_id: "54321", channel_id: "abcdefg"}
  )

  result = dispatcher.match_path(
    "/bogus/54321",
    ["accounts", {name: "account_id"}]
  )
  assert.equal(result, false)

  result = dispatcher.match_path(
    "/accounts/54321/channels",
    ["accounts", {name: "account_id"}]
  )
  assert.equal(result, false)


#class MockRequest

  #constructor: (options) ->
    #@url = options.url
    #@method = options.method
    #@headers = options.headers

#media_type = (type) ->
  #"application/vnd.spire-io.#{type}+json;version=1.0"

#request = new MockRequest
  #url: "http://localhost:1337/accounts"
  #method: "POST"
  #headers:
    #"Content-Type": media_type("account")
    #"Accept": media_type("session")

#result = dispatcher.dispatch(request)
#test "correctness", ->
  #assert.equal(result.resource_type, "account")
  #assert.equal(result.action_name, "create")

