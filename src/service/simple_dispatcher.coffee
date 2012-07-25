Classifier = require("./classifier")

class SimpleDispatcher

  constructor: (options) ->
    @schema = options.schema
    @http_interface = options.interface
    @map = options.map
    @handlers = options.handlers
    @install_default_handlers()

    @classifier = new Classifier(options)
    @error_handler = options.error_handler


  install_default_handlers: () ->
    dummy_handler = (context) ->
      {request, response, match} = context

      content = JSON.stringify
        status: 500
        message: "Unimplemented: #{match.resource_type}.#{match.action_name}"
      headers =
        "Content-Type": "application/json"
        "Content-Length": content.length
      response.writeHead 501, headers
      response.end(content)


    for resource, definition of @http_interface
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= dummy_handler

  class Context
    constructor: (@request, @response, @match) ->

  create_handler: () ->
    dispatcher = @
    (request, response) ->
      dispatcher.dispatch(request, response)

  dispatch: (request, response) ->
    result = @classifier.classify(request)
    if result.error
      @classification_error(result.error, request, response)
    else
      handler = @find_handler(result)
      context = new Context(request, response, result)
      handler(context)

  classification_error: (error, request, response) ->
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
    response.writeHead error.status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error)



module.exports = SimpleDispatcher
