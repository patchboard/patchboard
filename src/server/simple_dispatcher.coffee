URL = require("url")
Classifier = require("./classifier")
Context = require("./context")

class SimpleDispatcher

  constructor: (@service, @handlers) ->
    @supply_missing_handlers()


  supply_missing_handlers: () ->
    handler = @handlers.service.default

    for resource, definition of @service.resources
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= handler

  create_handler: () ->
    dispatcher = @
    (request, response) ->
      dispatcher.dispatch(request, response)

  dispatch: (request, response) ->
    @service.augment_request(request)
    match = @service.classify(request)
    if match.error
      @error_handler(match.error, response)
    else
      if match.content_type && @service.validator
        validation = @validate(match.content_type, request)
        if validation.errors.length > 0
          @error_handler(
            # TODO: more informative description
            {status: 400, message: "Bad Request", errors: validation.description},
            response
          )
          return


      handler = @find_handler(match)
      context = new Context(request, response, match)
      handler(context)

  validate: (media_type, request) ->
    @service.validator.validate {media_type: media_type}, request.body


  find_handler: (match) ->
    if resource = @handlers[match.resource_type]
      if action = resource[match.action_name]
        action
      else
        throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"
    else
      throw "No such resource: #{match.resource_type}"

  error_handler: (error, response) ->
    response.setHeader "Access-Control-Allow-Origin", "*"

    response.writeHead error.status,
      "Content-Type": "application/json"
    response.end JSON.stringify(error)



module.exports = SimpleDispatcher
