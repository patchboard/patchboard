util = require("util")
url = require("url")
matchers = require("./matchers")

class Dispatcher

  constructor: (options) ->
    @schema = options.schema
    @interface = options.interface
    @map = options.map
    
    @matchers = {}
    @process(@map)
    #string = JSON.stringify(@matchers, null, 2)
    #string = util.inspect(@matchers, false, 12)
    #console.log(string)

  process: (map) ->
    for resource_type, mapping of map
      resource = @interface[resource_type]
      paths = mapping.paths
      for path in paths
        path_matcher = @matchers[path] ||= new matchers.Path(path)
        path_matcher.matchers.type = "method"

        for action_name, definition of resource.actions

          # collect all the values from the interface description
          # that we will need to match against.
          method = definition.method
          authorization = definition.authorization || "none"

          if request_entity = definition.request_entity
            content_type = @schema[request_entity].media_type
          else
            content_type = "none"

          if response_entity = definition.response_entity
            accept = @schema[response_entity].media_type
          else
            accept = "none"

          # identifies the resource and action. will be stowed
          # in the last matcher
          payload =
            resource_type: resource_type
            action_name: action_name

          # create matchers and add to the tree
          path_matcher.matchers[method] ||= new matchers.Method(method)
          method_matcher = path_matcher.matchers[method]
          method_matcher.matchers.type = "authorization"

          #TODO: query matching

          method_matcher.matchers[authorization] ||=
            new matchers.Authorization(authorization)
          auth_matcher = method_matcher.matchers[authorization]
          auth_matcher.matchers.type = "content_type"

          auth_matcher.matchers[content_type] ||=
            new matchers.ContentType(content_type)
          ctype_matcher = auth_matcher.matchers[content_type]
          ctype_matcher.matchers.type = "accept"

          ctype_matcher.matchers[accept] ||=
            new matchers.Accept(accept, payload)
          accept_matcher = ctype_matcher.matchers[accept]

  

  dispatch: (request) ->
    url = url.parse(request.url)
    path = url.pathname
    method = request.method
    authorization = request.headers["Authorization"]
    content_type = request.headers["Content-Type"]
    accept = request.headers["Accept"]

    request_sequence = [
      path,
      method,
      authorization,
      content_type,
      accept
    ]
    console.log("request:", request_sequence)
    list = @try_sequence(request_sequence)
    matches = @compile_matches(list)
    match = matches[0]
    console.log("Match:", match)
    payload = match.payload
    delete match.payload
    for key, value of payload
      match[key] = value
    match

  try_sequence: (sequence) ->
    stage = @matchers
    current = [new MatchTracker(null, stage)]

    sequence_length = sequence.length - 1
    for i in [0..sequence_length]
      val = sequence[i]
      next = []
      while (tracker = current.shift())
        for identifier, matcher of tracker.stage
          data = matcher.match(val)
          if data
            if matcher.matchers
              next.push(tracker.track(matcher.matchers, matcher.type, data))
            else if matcher.payload
              next.push(tracker.track({}, "payload", matcher.payload))
      if i == sequence_length
        return next
      else if next.length == 0
        return false
      else
        current = next

  compile_matches: (list, val) ->
    matches = []
    for tracker in list
      path = [tracker.val]
      out = {}
      out[tracker.type] = tracker.val
      while (tracker = tracker.parent)
        if tracker.type
          out[tracker.type] = tracker.val
      matches.push(out)
    matches

class MatchTracker
  constructor: (@parent, @stage, @type, @val) ->

  track: (stage, type, val) ->
    new MatchTracker(@, stage, type, val)

module.exports = Dispatcher
