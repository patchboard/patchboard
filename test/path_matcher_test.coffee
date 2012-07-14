assert = require("assert")

helpers = require("./helpers")
test = helpers.test

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


