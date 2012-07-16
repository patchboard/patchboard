http = require("http")
Classifier = require("./classifier")

class SimpleDispatcher

  constructor: (options) ->
    @schema = options.schema
    @http_interface = options.interface
    @map = options.map
    @handlers = options.handlers
    @classifier = new Classifier(options)
    @error_handler = options.error_handler


  dispatch: (request, response) ->
    result = @classifier.classify(request)
    if result.error
      @classification_error(result.error, request, response)
    else
      handler = @find_handler(result.match)
      handler(request, response, result.data)

  classification_error: (kind, request, response) ->
    status = @statuses[kind] || 400
    error =
      status: status
      error: http.STATUS_CODES[status]
      description: "you goofed"

    if @error_handler
      @error_handler(error)
    else
      @default_error_handler(error, response)

  find_handler: (match) ->
    if resource = @handlers[match.resource_type]
      if action = resource[match.action_name]
        action
      else
        throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"
    else
      throw "No such resource: #{match.resource_type}"

  default_error_handler: (error, response) ->
    response.writeHead status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error)

  statuses:
    "authorization": 401
    "path": 404
    "query": 404
    "method": 405
    "accept": 406
    "content_type": 415

module.exports = SimpleDispatcher
