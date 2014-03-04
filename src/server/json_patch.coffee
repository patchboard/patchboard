{type} = require "fairmont"

process = (data) ->
  if type(data) == "array"
    process_array(data)
  else if type(data) == "object"
    process_object(data)
  else if type(data) == "string"
    process_string(data)

process_array = (array) ->
  for item in array
    process(item)

process_object = (object) ->
  for key, value of object
    process(value)

process_string = (string) ->
  if string == "__proto__"
    throw new Error "JSON input contained a string with value of '__proto__'"


parse = JSON.parse

JSON.parse = (string) ->
  data = parse(string)
  process(data)
  data

