class Path
  constructor: (mapping) ->
    @spec = @path_spec(mapping)
    @generate = @path_generator(@spec)

  tokenize_path: (string) ->
    tokens = string.slice(1).split("/")

  path_spec: (mapping) ->
    spec =
      components: []
      fields: {}
    path_string = (mapping.path || mapping.template)
    if !path_string
      throw new Error "Bad mapping: #{JSON.stringify(mapping)}"
    else
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
    expected_arity = Object.keys(spec.fields).length

    return (args...) ->
      out = spec.components.slice(0)

      if args.length == 1 && args[0].constructor == Object
        options = args[0]
        missing = (k for k, v of spec.fields when !options[k]?)
        if missing.length > 0
          throw new Error(
            "URL generation failed. Missing properties: #{missing.join(',')}"
          )

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
