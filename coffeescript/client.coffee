Shred = require("shred")

class Client

  constructor: (options) ->
    @client = new Shred()
    if options.service_url
      @service_url = options.service_url
      @client.request
        method: "get"
        url: @service_url
        headers:
          "Accept": "application/json"
        on:
          200: (response) ->
            @_schema = response.content.data.schema
          response: (response) ->
            console.log("whoops")
    else if options.schema
      @_schema = options.schema
    else
      throw "You did not initialize me properly"

  schema: (name) ->


module.exports = Client
