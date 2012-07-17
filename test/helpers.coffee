colors = require "colors"
assert = require "assert"

test = (name, fn) ->
  try
    fn()
    console.log colors.green("Pass: '#{name}'")
  catch error
    if error.name == "AssertionError"
      console.log colors.red("Fail: '#{name}':"), colors.red(error)
      console.log colors.white(error.stack)
    else
      console.log colors.yellow("Error: '#{name}':"), colors.yellow(error)
      console.log colors.white(error.stack)
    process.exit()

partial_equal = (actual, expected) ->
  for key, val of expected
    assert.deepEqual(actual[key], val)

patchboard =
  validate_dictionary: (dictionary, type) ->
    test "Dictionary contains items of type #{type}", ->
      for name in Object.keys(dictionary)
        assert.equal(dictionary[name].constructor.resource_type, type)



module.exports =
  test: test
  partial_equal: partial_equal
  patchboard: patchboard
