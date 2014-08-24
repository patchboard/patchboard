assert = require "assert"
Testify = require "testify"

complex = """
Digest username="Mufasa",realm="testrealm@host.com",nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",uri="/dir/index.html",qop=auth,nc=00000001,cnonce="0a4f113b",response="6629fae49393a05397450978507c4ef1",opaque="5ccc069c403ebaf9f0171e9517f40e41"
"""

parse = (string) ->
  [scheme, credentials] = string.split(" ")
  if scheme == "Basic"
    decoded = Buffer(credentials, "base64").toString("ascii")
    [login, password] = decoded.split(":")
    params = {login, password}
  else
    params = parse_params(credentials)
  {scheme, params}

parse_params = (string) ->
  params = {}
  parts = string.split(",")
  for part in parts
    [key, value] = part.split("=")
    # values may be tokens or quoted strings
    if (match = value.match /^"(.*)"$/)?
      params[key] = match[1]
    else
      params[key] = value

  params
  


Testify.test "Parsing Authorization header values", (context) ->

  context.test "Basic", ->
    {scheme, params} = parse("Basic c211cmY6c211cmZ5")
    assert.equal scheme, "Basic"
    assert.equal params.login, "smurf"
    assert.equal params.password, "smurfy"

  context.test "Everything else", ->
    {scheme, params} = parse(complex)
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

