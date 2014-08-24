class Path
  constructor: (options) ->
    {path, template} = options
    @type = "path"
    @matchers = {}
    if path
      @pattern = @parse_pattern(path)
    else if template
      @pattern = @parse_pattern(template)
    else
      throw new Error "Must specify a path or a template"

  parse_pattern: (pattern) ->
    captures = []
    # remove the initial "/"
    pattern = pattern.slice(1)
    components = pattern.split("/")
    for component in components
      if component.indexOf(":") == 0
        # path components that begin with ":" are parameter-capturers
        name = component.slice(1)
        captures.push({name: name})
      else
        # all other path components are exact matchers
        captures.push(component)
    captures

  match: (path) ->
    # TODO: uri escaping, if not handled by node http lib

    path_parts = path.slice(1).split("/")
    if path_parts.length == @pattern.length
      captured = {}
      for got, index in path_parts
        want = @pattern[index]
        if want.constructor == String
          if got != want
            return false
        else
          captured[want.name] = got

      captured
    else
      false

class Query
  constructor: (query_spec) ->
    @type = "query"
    @matchers = {}

    @spec = query_spec
    @spec.required ||= {}
    @spec.optional ||= {}

  # The query keys specified as required and optional
  # constitute a whitelist of allowed keys.
  match: (input) ->
    for key, value of input
      if !@spec.required[key] && !@spec.optional[key]
        return false
    for key, spec of @spec.required
      if !input[key]
        return false
    input



class Matcher
  constructor: (@value) ->
    @matchers = {}

  match: (input) ->
    if @value == "[any]"
      true
    else
      input == @value

class Method extends Matcher
  constructor: (method) ->
    @type = "method"
    super(method)

  match: (input) ->
    input == @value


class Authorization
  constructor: (arg) ->
    @matchers = {}
    if arg == "[any]"
      @schemes = arg
    else if arg.constructor == String
      @schemes = [arg]
    else
      @schemes = arg

    @type = "authorization"

  match: (input) ->
    if @schemes == "[any]"
      true
    else if input
      {scheme, params} = input
      if scheme in @schemes
        input
      else
        false
    else
      false



class ContentType extends Matcher
  # TODO: handle mediatypes in a better way than simple string match
  constructor: (content_type) ->
    @type = "content_type"
    super(content_type)

  match: (input) ->
    if @value == "[any]"
      true
    else
      if input == @value
        input
      else
        false

class Accept
  # TODO: handle mediatypes in a better way than simple string match
  constructor: (@value, @payload) ->
    @type = "accept"

  match: (input) ->
    if @value == "[any]"
      true
    else
      if input == @value
        input
      else
        false

module.exports =
  Path: Path
  Method: Method
  Query: Query
  Authorization: Authorization
  ContentType: ContentType
  Accept: Accept
