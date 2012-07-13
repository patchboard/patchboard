util = require("util")
class Dispatcher

  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map
    
    @matchers = {}
    @process_map(@map)
    string = util.inspect(@matchers, false, 10)
    #string = JSON.stringify(@matchers, null, 2)
    console.log(string)


  process_map: (map) ->
    for resource_type, mapping of map
      resource = @interface[resource_type]
      paths = mapping.paths
      for path in paths
        path_matcher = @matchers[path] ||= new PathMatcher(path)
        #pattern = @unpack_url_pattern(path)
        #path_matcher = @matchers[path] ||=
          #type: "path"
          #pattern: pattern
          #matchers: {}

        for action_name, definition of resource.actions
          method = definition.method
          method_matcher = path_matcher.matchers[method] ||=
            type: "method"
            value: method
            matchers: {}

          authorization = definition.authorization || "none"
          auth_matcher = method_matcher.matchers[authorization] ||=
            type: "authorization"
            value: authorization
            matchers: {}

          if request_entity = definition.request_entity
            content_type = @schema[request_entity].media_type
          else
            content_type = "none"

          ctype_matcher = auth_matcher.matchers[content_type] ||=
            type: "content_type"
            value: content_type
            matchers: {}

          if response_entity = definition.response_entity
            accept = @schema[response_entity].media_type
          else
            accept = "none"

          accept_matcher = ctype_matcher.matchers[accept] ||=
            type: "accept"
            value: accept
            payload:
              resource_type: resource_type
              action_name: action_name

  


  unpack_url_pattern: (pattern) ->
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

  match_path: (path, pattern) ->
    # TODO: uri escaping, if not handled by node http lib
    path_parts = path.slice(1).split("/")
    if path_parts.length == pattern.length
      out = {}
      for got, index in path_parts
        want = pattern[index]
        if want.constructor == String
          if got != want
            return false
        else
          out[want.name] = got

      out
    else
      false

   
  dispatch: (request) ->
    result = {}

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

  match_path: (path) ->
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

module.exports = Dispatcher
