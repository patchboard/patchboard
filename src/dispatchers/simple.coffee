URL = require("url")
Context = require("../context")

module.exports = class SimpleDispatcher

  constructor: (@service, handlers) ->
    @handlers = @service.default_handlers
    
    for resource, actions of handlers
      @handlers[resource] ||= {}
      for name, handler of actions
        @handlers[resource][name] = handler

    for resource, definition of @service.resources
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= @unimplemented

  request_listener: () ->
    (request, response) =>
      @dispatch(request, response)

  dispatch: (request, response) ->
    context = @service.context(request, response)
    {match} = context
    if context.match.error?
      # TODO: allow custom processing
      status = context.match.error.status
      context.set_cors_headers("*")
      context.respond status, match.error
    else
      @find_handler(context.match)(context)


  find_handler: (match) ->
    if !(resource = @handlers[match.resource_type])?
      throw "No such resource: #{match.resource_type}"

    if !(action = resource[match.action_name])?
      throw "Resource '#{match.resource_type}' has no such action: #{match.action_name}"

    action


  unimplemented: (context) ->
    {match} = context

    content = JSON.stringify
      message: "Unimplemented: #{match.resource_type}.#{match.action_name}"
    context.set_cors_headers("*")
    context.respond 501, content,
      "Content-Type": "application/json"
      "Content-Length": content.length


