assert = require("assert")
helpers = require("./helpers")
test = helpers.test

Patchboard = require("patchboard"

handlers =
  account_collection:
    create: (request, response, match_data) ->
      console.log "account collection create"
  account:
    update: (request, response, match_data) ->
      console.log "account update"

dispatcher = new Patchboard.Dispatcher
  interface: helpers.interface
  schema: helpers.schema
  map: helpers.map
  handlers: handlers



media_type = (type) ->
  "application/vnd.spire-io.#{type}+json;version=1.0"

class MockRequest

  constructor: (options) ->
    @url = options.url
    @method = options.method
    @headers = options.headers

class MockResponse
  constructor: (options) ->

request = new MockRequest
  url: "http://host/accounts"
  method: "POST"
  headers:
    "Content-Type": media_type("account")
    "Accept": media_type("session")
  
response = new MockResponse()
dispatcher.dispatch(request, response)




