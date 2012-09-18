http = require("http")
Matchers = require("./matchers")
PatchboardAPI = require("../patchboard_api")

class Classifier

  MATCH_ORDER = [
    "Path",
    "Method",
    "Query",
    "Authorization",
    "ContentType",
    "Accept"
  ]

  constructor: (service) ->
    @schema_manager = service.schema_manager
    @resources = service.resources
    @map = service.map
    
    @matchers = {}

    @process(PatchboardAPI.paths, PatchboardAPI.resources)
    @process(@map, @resources)

  # Given the path mappings and resource descriptions, set up the matching
  # structures required for classifying an HTTP request.
  process: (map, resources) ->
    for resource_type, mapping of map
      resource = resources[resource_type]
      path = mapping.path
      supported_methods = {}

      for action_name, definition of resource.actions
        supported_methods[definition.method] = true
        @register path, definition,
          resource_type: resource_type
          action_name: action_name
          success_status: definition.status

      # setup OPTIONS handling
      @register path, { method: "OPTIONS" },
        resource_type: "meta"
        action_name: "options"
        allow: Object.keys(supported_methods).sort()


  register: (path, definition, payload) ->
    sequence = @create_match_sequence(path, definition)
    @register_match_sequence(path, sequence, payload)

  # collect all the values from the resource description
  # that we will need to match against.
  create_match_sequence: (path, definition) ->
    # We use the MATCH_ORDER array (here and at classification time) to make sure
    # that we always present the facets of a request in the right order.
    # Each item in the "match sequence" we create here needs a string identifier
    # so it can be stored in the Object-based graph we use at classification time.
    # For most matcher types, the identifier is also suitable as a match specification,
    # but complex matches (e.g. Query) are expressed as objects, not strings.
    identifiers = {}
    specs = {}

    identifiers.Path = specs.Path = path
    identifiers.Method = specs.Method = definition.method
    identifiers.Authorization = specs.Authorization = definition.authorization || "[any]"

    if definition.query
      specs.Query = definition.query
      # create a string that uniquely identifies the query spec
      required_keys = (key for key, val of specs.Query.required).sort()
      optional_keys = (key for key, val of specs.Query.optional).sort()
      identifiers.Query =
        "required:(#{required_keys.join("&")}), optional:(#{optional_keys.join("&")})"
    else
      specs.Query = {}
      identifiers.Query = "none"

    if request_schema = definition.request_schema
      schema = @schema_manager.find(request_schema)
      if schema
        identifiers.ContentType = specs.ContentType = schema.mediaType
      else
        throw "No schema found for #{request_schema}"

    else
      identifiers.ContentType = specs.ContentType = "[any]"

    if response_schema = definition.response_schema
      schema = @schema_manager.find(name: response_schema)
      if schema
        identifiers.Accept = specs.Accept = schema.mediaType
      else
        throw "No schema found for #{response_schema}"
    else if definition.accept
      identifiers.Accept = specs.Accept = definition.accept
    else
      identifiers.Accept = specs.Accept = "[any]"


    sequence = []
    for type in MATCH_ORDER
      sequence.push
        klass: Matchers[type]
        ident: identifiers[type]
        spec: specs[type]

    sequence

  register_match_sequence: (path, sequence, payload) ->
    matchers = @matchers
    for item in sequence
      matchers[item.ident] ||= new item.klass(item.spec)
      matcher = matchers[item.ident]
      matchers = matcher.matchers
    matcher.payload = payload



  # Given an HTTP request, returns either an error or a result object.
  # The result object contains properties indicating the resource_type
  # and action_name which should handle the request.  Users of this method
  # may then find and use handler functions as they see fit.
  classify: (request) ->
    headers = request.headers
    components =
      Path: request.path
      Query: request.query
      Method: request.method
      Authorization: headers["authorization"] || headers["Authorization"]
      ContentType: headers["content-type"] || headers["Content-Type"]
      Accept: headers["accept"] || headers["Accept"]

    # the request sequence uses pseudo-tuples so that we can
    # tell at what stage match failures occur.  This is crucial 
    # to the determination of the appropriate error code (404, 406, etc.)
    sequence = []
    for type in MATCH_ORDER
      sequence.push [type, components[type]]

    results = @match_request_sequence(sequence)
    if results.error
      results
    else
      matches = @compile_matches(results)
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
    "Authorization": 401
    "Path": 404
    "Query": 404
    "Method": 405
    "Accept": 406
    "ContentType": 415


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
    # Sort by the number of interesting pieces of data
    # tracked during matching.  This trick pushes matchers without
    # wildcards higher than those that have them.
    matches.sort (item) -> Object.keys(item).length

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
