colors = require "colors"
EventEmitter = require("events").EventEmitter

# Test functions that take no arguments are treated as
# wholly synchronous.  Test functions that take one argument
# are provided a context object that makes provisions for
# asynchronous usage.  The two primary provisions are the
# `safely` function, used for wrapping callbacks in testliness;
# and the `done` method, which signals the end (and success)
# of a test.
test = (name, fn) ->
  try
    if fn.length == 0
      fn()
      success(name)
    else
      context = create_context(name)
      context.emitter.on "done", () -> success(name)
      fn(context)
  catch error
    failure(name, error)
    process.exit()

success = (name) -> console.log colors.green("Pass: '#{name}'")

failure = (name, error) ->
  if error.name == "AssertionError"
    console.log colors.red("Fail: '#{name}'\n#{error}")
  else
    console.log colors.yellow("Error: '#{name}'\n#{error}")
  # split,slice to remove the error message from the stack trace
  if error.stack
    console.log colors.white(error.stack.split("\n").slice(1).join("\n"))
  process.exit()

assertions = (test_name) ->
  wrapped = {}
  for name, fn of require("assert")
    wrapped[name] = wrap_assertion(test_name, fn)
  # custom assertions
  wrapped.partialEqual = wrap_assertion test_name, (actual, expected) ->
    for key, val of expected
      assert.deepEqual(actual[key], val)
  wrapped

wrap_assertion = (test_name, fn) ->
  (args...) ->
    try
      fn(args...)
    catch error
      failure(test_name, error)

create_context = (name) ->
  emitter = new EventEmitter
  context =
    name: name
    emitter: emitter
    done: () -> emitter.emit("done")
    wrap: (callback) ->
      (args...) ->
        try
          callback(args...)
        catch error
          failure(name, error)
    assert: assertions(name)

#assert.partialEqual = (actual, expected) ->
  #for key, val of expected
    #assert.deepEqual(actual[key], val)

module.exports = test

