assert = require "assert"
module.exports =
  api: require("../src/example_api")

  partial_equal: (actual, expected) ->
    for key, val of expected
      assert.deepEqual(actual[key], val)

