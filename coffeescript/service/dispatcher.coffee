util = require("util")
URL = require("url")
matchers = require("./matchers")

class Dispatcher

  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map
    
    @matchers = {}
    @process(@map)

  process: (map) ->
    for resource_type, mapping of map
      resource = @interface[resource_type]
      paths = mapping.paths
      for path in paths

        for action_name, definition of resource.actions


          # collect all the values from the interface description
          # that we will need to match against.
          method = definition.method

          if definition.query
          #if definition.query?.required
            query_spec = definition.query
            query_ident = Object.keys(query_spec).sort().join("&")
          else
            query_spec = {}
            query_ident = "none"


          authorization = definition.authorization || "pass"

          if request_entity = definition.request_entity
            content_type = @schema[request_entity].media_type
          else
            content_type = "pass"

          if response_entity = definition.response_entity
            accept = @schema[response_entity].media_type
          else
            accept = "pass"

          # identifies the resource and action. will be stowed
          # in the last matcher
          payload =
            resource_type: resource_type
            action_name: action_name

          # create matchers and add to the tree
          path_matcher = @matchers[path] ||= new matchers.Path(path)

          path_matcher.matchers[method] ||= new matchers.Method(method)
          method_matcher = path_matcher.matchers[method]

          #TODO: query matching
          method_matcher.matchers[query_ident] ||= new matchers.Query(query_spec)
          query_matcher = method_matcher.matchers[query_ident]

          query_matcher.matchers[authorization] ||=
            new matchers.Authorization(authorization)
          auth_matcher = query_matcher.matchers[authorization]

          auth_matcher.matchers[content_type] ||=
            new matchers.ContentType(content_type)
          ctype_matcher = auth_matcher.matchers[content_type]

          ctype_matcher.matchers[accept] ||=
            new matchers.Accept(accept, payload)
          accept_matcher = ctype_matcher.matchers[accept]

  

  dispatch: (request) ->
    url = URL.parse(request.url)
    path = url.pathname
    method = request.method
    authorization = request.headers["Authorization"]
    content_type = request.headers["Content-Type"]
    accept = request.headers["Accept"]
    if url.query
      query_parts = url.query.split("&")
      query = {}
      for part in query_parts
        [key, value] = part.split("=")
        query[key] = value
    else
      query = {}

    request_sequence = [
      ["path", path],
      ["method", method],
      ["query", query],
      ["authorization", authorization],
      ["content_type", content_type],
      ["accept", accept]
    ]
    #console.log("request:", request_sequence)
    results = @try_sequence(request_sequence)
    if results.error
      results
    else
      matches = @compile_matches(results)
      #console.log("Matches:", matches)
      match = matches[0]
      payload = match.payload
      delete match.payload
      for key, value of payload
        match[key] = value
      match

  # this code was stolen and adapted from Djinn, which 
  # is why it looks so hideous.  Not that Djinn is hideous,
  # just that you're seeing it out of context.
  try_sequence: (sequence) ->
    stage = @matchers
    current = [new MatchTracker(null, stage)]

    last_index = sequence.length - 1
    for i in [0..last_index]
      [type, val] = sequence[i]
      next = []
      while (tracker = current.shift())
        for identifier, matcher of tracker.stage
          data = matcher.match(val)
          if data
            if matcher.matchers
              next.push(tracker.track(matcher.matchers, matcher.type, data))
            else if matcher.payload
              # This is a hack necessitated by the nature of the code adapted
              # from Djinn.  The whole sequence-matching and match-compiling
              # logic should be reworked for appropriateness to this project.
              t = tracker.track({}, matcher.type, data)
              next.push(t.track({}, "payload", matcher.payload))
      if i == last_index
        if next.length == 0
          return {error: type}
        return next
      else if next.length == 0
        return {error: type}
      else
        current = next

  compile_matches: (list, val) ->
    matches = []
    for tracker in list
      out = {}
      if tracker.val != true
        out[tracker.type] = tracker.val
      while (tracker = tracker.parent)
        if tracker.type
          if tracker.val != true
            out[tracker.type] = tracker.val
      matches.push(out)
    matches

class MatchTracker
  constructor: (@parent, @stage, @type, @val) ->

  track: (stage, type, val) ->
    new MatchTracker(@, stage, type, val)

module.exports = Dispatcher
