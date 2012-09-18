class Path
  constructor: (path_string) ->
    @spec = @path_spec(path_string)
    @generate = @path_generator(@spec)

  tokenize_path: (string) ->
    tokens = string.slice(1).split("/")

  path_spec: (path_string) ->
    spec =
      components: []
      fields: {}
    tokens = @tokenize_path(path_string)
    for token, index in tokens
      if token.indexOf(":") == 0
        name = token.slice(1)
        spec.fields[name] = index
        spec.components.push(null)
      else
        # all other path components are exact matchers
        spec.components.push(token)
    spec

  path_generator: (spec) ->
    service = @
    expected_keys = Object.keys(spec.fields).sort().join(",")
    expected_arity = Object.keys(spec.fields).length

    return (args...) ->
      out = spec.components.slice(0)

      if args.length == 1 && args[0].constructor == Object
        # url template will be filled in using properties from the args object
        options = args[0]
        input_keys = Object.keys(options).sort().join(",")
        if input_keys != expected_keys
          # TODO: add explanation to error
          console.log expected_keys, input_keys
          throw "Input properties not suitable to generate URL"
        for name, index of spec.fields
          value = options[name]
          # TODO: validate that the value is not an array or object
          out[index] = value

      else if args.length == expected_arity
        # template filled in positionally
        for value, index in out
          if value == null
            out[index] = args.shift()
      else
        # TODO: explain why
        throw "Wrong number of arguments for URL generation"

      "/#{out.join("/")}"


module.exports = Path
