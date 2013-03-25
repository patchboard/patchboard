class Path
  constructor: (pattern) ->
    @type = "path"
    @pattern = @parse_pattern(pattern)
    @matchers = {}

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



class Basic
  constructor: (@value) ->
    @matchers = {}

  match: (input) ->
    if @value == "[any]"
      true
    else
      input == @value

class Method extends Basic
  constructor: (method) ->
    @type = "method"
    super(method)

  match: (input) ->
    input == @value


class Authorization extends Basic
  constructor: (authorization) ->
    @type = "authorization"
    super(authorization)

  match: (input) ->
    if @value == "[any]"
      true
    else if input
      scheme = input.split(" ")[0]
      scheme == @value
    else
      false

class ContentType extends Basic
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
    #@matchers = {}

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
