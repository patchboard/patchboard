Shred = require("shred")

class Quern

  constructor: (@service_url) ->
    @client = new Shred()
