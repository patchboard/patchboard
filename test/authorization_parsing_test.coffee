assert = require "assert"
Testify = require "testify"

{parse} = require "../src/authorization"

spaceless = """
Digest username="Mufasa",realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",uri="/dir/index.html",qop=auth,nc=00000001,cnonce="0a4f113b",response="6629fae49393a05397450978507c4ef1",opaque="5ccc069c403ebaf9f0171e9517f40e41"
"""

spaced = """
Digest username="Mufasa",
  realm="testrealm@host.com",
  nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
  uri="/dir/index.html",
  qop=auth,
  nc=00000001,
  cnonce="0a4f113b",
  response="6629fae49393a05397450978507c4ef1",
  opaque="5ccc069c403ebaf9f0171e9517f40e41"
"""
  
Testify.test "Parsing Authorization header values", (context) ->

  context.test "Basic", ->
    {scheme, params} = parse("Basic c211cmY6c211cmZ5")
    assert.equal scheme, "Basic"
    assert.equal params.login, "smurf"
    assert.equal params.password, "smurfy"

  context.test "params with no spaces", ->
    {scheme, params} = parse(spaceless)
    assert.equal scheme, "Digest"
    assert.deepEqual params, {
      username: "Mufasa"
      realm: "testrealm@host.com"
      nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093"
      uri: "/dir/index.html"
      qop: "auth"
      nc: "00000001"
      cnonce: "0a4f113b"
      response: "6629fae49393a05397450978507c4ef1"
      opaque: "5ccc069c403ebaf9f0171e9517f40e41"
    }

  context.test "with spaces", ->
    {scheme, params} = parse(spaced)
    assert.equal scheme, "Digest"
    assert.deepEqual params, {
      username: "Mufasa"
      realm: "testrealm@host.com"
      nonce: "dcd98b7102dd2f0e8b11d0f600bfb0c093"
      uri: "/dir/index.html"
      qop: "auth"
      nc: "00000001"
      cnonce: "0a4f113b"
      response: "6629fae49393a05397450978507c4ef1"
      opaque: "5ccc069c403ebaf9f0171e9517f40e41"
    }

  context.test "Invalid", ->
    assert.throws ->
      parse "Smurf "

    assert.throws ->
      parse "Smurf smurfy"

    assert.throws ->
      x = parse "Smurf color=blue hat=white"
      console.log x

