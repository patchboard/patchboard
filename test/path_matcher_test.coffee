assert = require("assert")

helpers = require("./helpers")
test = require("../src/testify").test

matchers = require("../src/service/matchers")

PathMatcher = matchers.Path

test "Path matching for '/'", ->
  matcher = new PathMatcher("/")
  assert.deepEqual(
    matcher.match("/"),
    {}
  )
  assert.equal(
    matcher.match("/foo"),
    false
  )

test "Path matching, capturing last component", ->
  matcher = new PathMatcher("/accounts/:account_id")
  assert.deepEqual(
    matcher.pattern,
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

test "Path matching, capturing middle component", ->
  matcher = new PathMatcher("/accounts/:account_id/channels")
  assert.deepEqual(
    matcher.pattern,
    ["accounts", {name: "account_id"}, "channels"]
  )

test "Path matching, capturing multiple components", ->
  matcher = new PathMatcher("/accounts/:account_id/channels/:channel_id")
  assert.deepEqual(
    matcher.pattern,
    ["accounts", {name: "account_id"}, "channels", {name: "channel_id"}]
  )
  assert.deepEqual(
    matcher.match("/accounts/54321/channels/abcdefg"),
    {account_id: "54321", channel_id: "abcdefg"}
  )


