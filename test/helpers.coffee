assert = require "assert"
module.exports =
  api: require("../src/example_api")

  partial_equal: (actual, expected) ->
    for key, val of expected
      if got = actual[key]
        assert.deepEqual(actual[key], val)
      else
        assert.fail got, val, "No value found for '#{key}'"

