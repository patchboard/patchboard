assert = require("assert")
Testify = require "testify"

matchers = require("../src/server/matchers")

PathMatcher = matchers.Path

Testify.test "Path matching", (context) ->
  context.test "for '/'", ->
    matcher = new PathMatcher(path: "/")
    assert.deepEqual(
      matcher.match("/"),
      {}
    )
    assert.equal(
      matcher.match("/foo"),
      false
    )

  context.test "capturing last component", ->
    matcher = new PathMatcher(template: "/accounts/:account_id")
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

  context.test "capturing middle component", ->
    matcher = new PathMatcher(template: "/accounts/:account_id/channels")
    assert.deepEqual(
      matcher.pattern,
      ["accounts", {name: "account_id"}, "channels"]
    )

  context.test "capturing multiple components", ->
    matcher = new PathMatcher(template: "/accounts/:account_id/channels/:channel_id")
    assert.deepEqual(
      matcher.pattern,
      ["accounts", {name: "account_id"}, "channels", {name: "channel_id"}]
    )
    assert.deepEqual(
      matcher.match("/accounts/54321/channels/abcdefg"),
      {account_id: "54321", channel_id: "abcdefg"}
    )


