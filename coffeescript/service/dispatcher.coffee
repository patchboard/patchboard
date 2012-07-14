util = require("util")
URL = require("url")
Matchers = require("./matchers")

class Dispatcher

  constructor: (options) ->
    @schema = options.schema
    @http_interface = options.interface
    @map = options.map
    
    @matchers = {}
    @process(@map, @http_interface)

  # Given URL map and HTTP interface objects, set up the matching
  # structures required for dispatching an HTTP request.
  process: (map, http_interface) ->
    for resource_type, mapping of map
      resource = http_interface[resource_type]
      paths = mapping.paths
      for path in paths

        for action_name, definition of resource.actions
          match_sequence = @create_match_sequence(path, action_name, definition)

          matchers = @matchers
          for item in match_sequence
            matchers[item.ident] ||= new item.klass(item.spec)
            matcher = matchers[item.ident]
            matchers = matcher.matchers

          matcher.payload =
            resource_type: resource_type
            action_name: action_name


   create_match_sequence: (path, action_name, definition) ->
    # collect all the values from the interface description
    # that we will need to match against.
    method = definition.method

    if definition.query
      query_spec = definition.query
      # create a string that uniquely identifies the query spec
      required_keys = (key for key, val of query_spec.required).sort()
      optional_keys = (key for key, val of query_spec.optional).sort()
      query_ident = "r:#{required_keys.join("&")},o:#{optional_keys.join("&")}"
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

    # NOTE: matching depends on the order of this match sequence
    # being consistent with the order of the request sequence. If
    # you change one, you must change the other.
    [
      {klass: Matchers.Path, ident: path, spec: path},
      {klass: Matchers.Method, ident: method, spec: method},
      {klass: Matchers.Query, ident: query_ident, spec: query_spec},
      {klass: Matchers.Authorization, ident: authorization, spec: authorization},
      {klass: Matchers.ContentType, ident: content_type, spec: content_type},
      {klass: Matchers.Accept, ident: accept, spec: accept},
    ]


  # Given an HTTP request, returns either an error or a result object.
  # The result object contains properties indicating the resource_type
  # and action_name which should handle the request.  Users of this method
  # may then find and use handler functions as they see fit.
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

    # the request sequence uses pseudo-tuples so that we can
    # tell at what stage match failures occur.  This is crucial 
    # to the determination of the appropriate error code (404, 406, etc.)
    request_sequence = [
      ["path", path],
      ["method", method],
      ["query", query],
      ["authorization", authorization],
      ["content_type", content_type],
      ["accept", accept]
    ]
    results = @match_request_sequence(request_sequence)
    if results.error
      results
    else
      matches = @compile_matches(results)
      match = matches[0]
      payload = match.payload
      delete match.payload
      for key, value of payload
        match[key] = value
      match

  # this code was stolen and adapted from Djinn, which 
  # is why it looks so hideous.  Not that Djinn is hideous,
  # just that you're seeing it out of context.
  match_request_sequence: (sequence) ->
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
