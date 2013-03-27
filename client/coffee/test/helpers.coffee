assert = require "assert"
SchemaManager = require("../schema_manager")

api = require("../../../coffee/example_api")
api.directory = {}
SchemaManager.normalize(api.schema)

module.exports =
  api:
    directory: {}
    resources: api.resources
    schemas: [api.schema]

  partial_equal: (actual, expected) ->
    for key, val of expected
      assert.deepEqual(actual[key], val)

