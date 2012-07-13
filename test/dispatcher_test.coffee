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

matchers = require("../coffeescript/service/matchers")

PathMatcher = matchers.Path

test "Path matching", ->
  matcher = new PathMatcher("/accounts/:account_id")
  assert.deepEqual(
    matcher.value,
    ["accounts", {name: "account_id"}]
  )
  result = matcher.match("/accounts/54321",)
  assert.deepEqual(
    result,
    {account_id: "54321"}
  )
  assert.equal(
    matcher.match("/bogus/12345"),
    false
  )
  assert.equal(
    matcher.match("/accounts/12345/channels"),
    false
  )

  matcher = new PathMatcher("/accounts/:account_id/channels")
  assert.deepEqual(
    matcher.value,
    ["accounts", {name: "account_id"}, "channels"]
  )

  matcher = new PathMatcher("/accounts/:account_id/channels/:channel_id")
  assert.deepEqual(
    matcher.value,
    ["accounts", {name: "account_id"}, "channels", {name: "channel_id"}]
  )
  assert.deepEqual(
    matcher.match("/accounts/54321/channels/abcdefg"),
    {account_id: "54321", channel_id: "abcdefg"}
  )


class MockRequest

  constructor: (options) ->
    @url = options.url
    @method = options.method
    @headers = options.headers


media_type = (type) ->
  "application/vnd.spire-io.#{type}+json;version=1.0"

request = new MockRequest
  url: "http://localhost:1337/account/12345"
  method: "GET"
  headers:
    "Accept": media_type("account")
    "Authorization": "Capability monkeys"

result = dispatcher.dispatch(request)
test "simple dispatch", ->
  assert.equal(result.resource_type, "account")
  assert.equal(result.action_name, "get")


request = new MockRequest
  url: "http://localhost:1337/account/12345/channels?name=smurf"
  method: "GET"
  headers:
    "Accept": media_type("channels")
    "Authorization": "Capability monkeys"

result = dispatcher.dispatch(request)
test "query matching", ->
  assert(result)
  assert.equal(result.resource_type, "channel_collection")
  assert.equal(result.action_name, "get_by_name")
