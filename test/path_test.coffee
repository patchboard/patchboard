assert = require("assert")

helpers = require("./helpers")
testify = require("../src/testify")

api = require("./sample_api.coffee")
Path = require("../src/service/path")

#testify "service.path_spec", ->
  #spec = service.path_spec("/things")
  #assert.deepEqual spec,
    #components: ["things"]
    #fields: {}

  #spec = service.path_spec("/things/:thing_id")
  #assert.deepEqual spec,
    #components: ["things", null]
    #fields: {thing_id: 1}

  #spec = service.path_spec("/things/:thing_id/subthings")
  #assert.deepEqual spec,
    #components: ["things", null, "subthings"]
    #fields: {thing_id: 1}

  #spec = service.path_spec("/things/:thing_id/subthings/:subthing_id")
  #assert.deepEqual spec,
    #components: ["things", null, "subthings", null]
    #fields: {thing_id: 1, subthing_id: 3}
