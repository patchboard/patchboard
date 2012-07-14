class PathMatcher
  constructor: (pattern) ->
    @type = "path"
    @pattern = @parse_pattern(pattern)
    @matchers = {}

  parse_pattern: (pattern) ->
    out = []
    # for now, we assume that all patterns begin with "/".
    # I'm not sure there's any value to allowing it otherwise.
    pattern = pattern.slice(1)
    components = pattern.split("/")
    for component in components
      if component.indexOf(":") == 0
        name = component.slice(1)
        out.push({name: name})
      else
        out.push(component)
    out

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

class QueryMatcher
  #name:
    #description: "The exact name of the subscription"
    #type: "string"
  constructor: (query_spec) ->
    @type = "query"
    @matchers = {}

    @spec = query_spec
    @spec.required ||= {}
    @spec.optional ||= {}

  match: (input) ->
    for key, value of input
      if !@spec.required[key] && !@spec.optional[key]
        return false
    for key, spec of @spec.required
      if !input[key]
        return false
    true



class BasicMatcher
  constructor: (@value) ->
    @matchers = {}

  match: (input) ->
    if @value == "pass"
      true
    else
      input == @value

class MethodMatcher extends BasicMatcher
  constructor: (method) ->
    @type = "method"
    super(method)

  match: (input) ->
    input == @value


class AuthorizationMatcher extends BasicMatcher
  constructor: (authorization) ->
    @type = "authorization"
    super(authorization)

  match: (input) ->
    if @value == "pass"
      true
    else if input
      scheme = input.split(" ")[0]
      scheme == @value
    else
      false

class ContentTypeMatcher extends BasicMatcher
  # TODO: handle mediatypes in a better way than simple string match
  constructor: (content_type) ->
    @type = "content_type"
    super(content_type)

class AcceptMatcher
  # TODO: handle mediatypes in a better way than simple string match
  constructor: (@value, @payload) ->
    @type = "accept"
    #@matchers = {}

  match: (input) ->
    if @value == "pass"
      true
    else
      if input == @value
        input
      else
        false

module.exports =
  Path: PathMatcher
  Method: MethodMatcher
  Query: QueryMatcher
  Authorization: AuthorizationMatcher
  ContentType: ContentTypeMatcher
  Accept: AcceptMatcher
