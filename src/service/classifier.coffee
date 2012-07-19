http = require("http")
util = require("util")
URL = require("url")
Matchers = require("./matchers")

class Classifier

  constructor: (options) ->
    @schema = options.schema.properties
    @http_interface = options.interface
    @map = options.map
    
    @matchers = {}
    @process(@map, @http_interface)

  # Given URL map and HTTP interface objects, set up the matching
  # structures required for classifying an HTTP request.
  process: (map, http_interface) ->
    for resource_type, mapping of map
      resource = http_interface[resource_type]
      paths = mapping.paths
      for path in paths
        supported_methods = {}

        for action_name, definition of resource.actions
          supported_methods[definition.method] = true
          match_sequence = @create_match_sequence(path, definition)

          matchers = @matchers
          for item in match_sequence
            matchers[item.ident] ||= new item.klass(item.spec)
            matcher = matchers[item.ident]
            matchers = matcher.matchers

          matcher.payload =
            resource_type: resource_type
            action_name: action_name

        # setup OPTIONS handling
        match_sequence = @create_match_sequence path,
          method: "OPTIONS"
        matchers = @matchers
        for item in match_sequence
          matchers[item.ident] ||= new item.klass(item.spec)
          matcher = matchers[item.ident]
          matchers = matcher.matchers

        matcher.payload =
          resource_type: "meta"
          action_name: "options"
          allow: Object.keys(supported_methods)


  # collect all the values from the interface description
  # that we will need to match against.
   create_match_sequence: (path, definition) ->

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
      content_type = @schema[request_entity].mediaType
    else
      content_type = "pass"

    if response_entity = definition.response_entity
      accept = @schema[response_entity].mediaType
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
  classify: (request) ->
    url = URL.parse(request.url)
    path = url.pathname
    method = request.method
    console.log(method)
    headers = request.headers
    authorization = headers["authorization"] || headers["Authorization"]
    content_type = headers["content-type"] || headers["Content-Type"]
    accept = headers["accept"] || headers["Accept"]
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
      if matches.length > 1
        payloads = (match.payload for match in matches)
        console.log """
        Dispatching found more than one candidate, so we're using the first.
        Match payloads:
        """
        for payload in payloads
          console.log(payload)
      # first match, obviously. compile_matches is a good place
      # to sort the matches based on whatever criteria we decide
      # to use.
      match = matches[0]
      # TODO: this is ugly; can we improve?
      for k,v of match.payload
        match[k] = v
      delete match.payload
      match

  # this code was stolen and adapted from Djinn, which 
  # is why it looks so hideous.  Not that Djinn is hideous,
  # just that you're seeing it out of context. It's a messy,
  # arguably perverted, variant of the famous Thompson algorithm for
  # testing NFA acceptance.
  # See http://swtch.com/~rsc/regexp/regexp1.html, specifically the
  # section with heading "Implementation: Simulating the NFA"
  match_request_sequence: (sequence) ->
    root_tracker = new MatchTracker(null, matchers: @matchers)
    current = [root_tracker]

    # breadth-first traversal
    last_index = sequence.length - 1
    # `type` here describes what part of the request we're matching against
    for [type, value], i in sequence
      next = []
      for tracker in current
        for _identifier, matcher of tracker.matchers
          match_data = matcher.match(value)
          if match_data
            if matcher.matchers
              t = tracker.child
                matchers: matcher.matchers
                type: matcher.type
                data: match_data
              next.push(t)
            else if matcher.payload
              next.push tracker.child(
                matchers: {}, type: matcher.type,
                data: match_data, payload: matcher.payload
              )
            else
              throw "Sentinel: a matcher should have a payload or more matchers"
      if next.length == 0
        # we need to know at what stage the request classification failed
        # so that we can respond with the proper status code.
        return {error: @create_error(type)}
        #return {error: type}
      else if i == last_index
        # if we're on the last element in the request sequence, then the
        # presence of trackers in the next array indicates successful matches.
        return next
      else
        # get set for the next stage
        current = next

  create_error: (kind) ->
    status = @statuses[kind] || 400
    error =
      status: status
      message: http.STATUS_CODES[status]
      description: "Problem with request"

  statuses:
    "authorization": 401
    "path": 404
    "query": 404
    "method": 405
    "accept": 406
    "content_type": 415


  compile_matches: (list, val) ->
    matches = []
    for tracker in list
      out = {}
      out.payload = tracker.payload
      if tracker.data != true
        out[tracker.type] = tracker.data
      while (tracker = tracker.parent)
        if tracker.type
          if tracker.data != true
            out[tracker.type] = tracker.data
      matches.push(out)
    matches

# while attempting to match the request, we're going to construct
# a tree containing all the matchers that match facets of the request.
# Then at the end, we can take the remaining leaf nodes and pop back
# up, parent-wise, to gather the data collected for each successful
# classification.
class MatchTracker
  constructor: (@parent, options) ->
    @matchers = options.matchers
    @type = options.type
    @data = options.data
    @payload = options.payload

  child: (options) ->
    new MatchTracker(@, options)

module.exports = Classifier
