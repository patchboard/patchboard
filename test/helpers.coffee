colors = require "colors"
assert = require "assert"
EventEmitter = require("events").EventEmitter

# Test functions that take no arguments are treated as
# wholly synchronous.  Test functions that take one argument
# are provided a context object that makes provisions for
# asynchronous usage.  The two primary provisions are the
# `safely` function, used for wrapping callbacks in testliness;
# and the `done` method, which signals the end (and success)
# of a test.
test = (name, fn) ->
  arity = fn.length
  if arity == 0
    try
      fn(context)
      console.log colors.green("Pass: '#{name}'")
    catch error
      failure(name, error)
      process.exit()
  else
    context = create_context()
    context.emitter.on "done", () ->
      console.log colors.green("Pass: '#{name}'")
    try
      fn(context)
    catch error
      failure(name, error)
      process.exit()

failure = (name, error) ->
  if error.name == "AssertionError"
    console.log colors.red("Fail: '#{name}':"), colors.red(error)
    console.log colors.white(error.stack)
  else
    console.log colors.yellow("Error: '#{name}':"), colors.yellow(error)
    console.log colors.white(error.stack)

partial_equal = (actual, expected) ->
  for key, val of expected
    assert.deepEqual(actual[key], val)

create_context = (name) ->
  emitter = new EventEmitter()
  name: name
  emitter: emitter
  done: () ->
    emitter.emit("done")
  safely: (callback) ->
    (error, result) ->
      if error
        failure(name, error)
      else
        fn(callback)

module.exports =
  test: test
  partial_equal: partial_equal
