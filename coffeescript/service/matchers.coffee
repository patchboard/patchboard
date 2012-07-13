class PathMatcher
  constructor: (pattern) ->
    @type = "path"
    @value = @parse_pattern(pattern)
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
    if path_parts.length == @value.length
      out = {}
      for got, index in path_parts
        want = @value[index]
        if want.constructor == String
          if got != want
            return false
        else
          out[want.name] = got

      out
    else
      false

class QueryMatcher
  #name:
    #description: "The exact name of the subscription"
    #type: "string"
  constructor: (query_spec) ->
    @type = "query"
    @value = query_spec
    @matchers = {}

  match: (input) ->
    if @value == "none"
      true
    else
      out = {}
      for key, spec of @value
        if input[key]
          out[key] = input[key]
        else
          return false
      out


class BasicMatcher
  constructor: (@value) ->
    @matchers = {}

  match: (input) ->
    if @value == "none"
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
    if @value == "none"
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
    if @value == "none"
      true
    else
      input == @value

module.exports =
  Path: PathMatcher
  Method: MethodMatcher
  Query: QueryMatcher
  Authorization: AuthorizationMatcher
  ContentType: ContentTypeMatcher
  Accept: AcceptMatcher
