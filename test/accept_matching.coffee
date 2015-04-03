assert = require("assert")
Testify = require "testify"
{Accept} = require "../src/server/matchers"

Testify.test "Accept matching", (context) ->
  matcher = new Accept("application/vnd.pb.test+json;version=1")

  context.test "no matching types", ->
    assert.equal(
      matcher.match("image/png"),
      false
    )

  context.test "exact match for type in spec", ->
    accept = "application/vnd.pb.test+json;version=1"
    #console.error accept.types.getBestMatch [ "application/vnd.pb.test+json;version=1" ]
    assert.equal(
      matcher.match(accept),
      "application/vnd.pb.test+json;version=1"
    )


  context.test "equivalent match for type in spec", ->
    accept = "application/vnd.pb.test+json; version=1"
    assert.equal(
      matcher.match(accept),
      "application/vnd.pb.test+json;version=1"
    )

  context.test "version mismatch", ->
    accept = "application/vnd.pb.test+json; version=2"
    assert.equal(
      matcher.match(accept),
      "application/vnd.pb.test+json;version=1"
    )

  context.test "multiple types in accept header", ->
    accept = "application/vnd.pb.test+json; version=1.0; charset=UTF-8,image/webp"
    assert.equal(
      matcher.match(accept),
      "application/vnd.pb.test+json;version=1"
    )

