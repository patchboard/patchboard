
# Example handler function:
#  (details, callback) ->
#    {resource, action, authorization, identifier, query, content} = details
#    {topic} = content
#    callback null, {description: "#{topic} is smurfy"}

module.exports = class AdapterDispatcher

  constructor: (@service, @handlers) ->
    # Handlers for built-in resources, such as the API definition.
    for resource, actions of @service.default_handlers
      handlers[resource] ||= {}
      for name, handler of actions
        handlers[resource][name] = handler

    # Fill in missing handlers with a default error handler.
    for resource, definition of @service.resources
      for action, spec of definition.actions
        @handlers[resource] ||= {}
        @handlers[resource][action] ||= @unimplemented

  request_listener: () ->
    (request, response) =>

    context = @service.context(request, response)
    unless context.match.error?
      details = @format(context)
      callback = @create_callback(context)
      @find_handler(context.match)(details, callback)

  format: ({match, request}) ->
    {resource_type, action_name} = match
    {
      resource: resource_type
      action: action_name
      authorization: match.authorization
      identifier: match.path
      query: match.query
      content: request.body
    }

  create_callback: (context) ->
    (error, result) ->
      if error
        context.error error.message, error.reason
      else
        status = context.match.success_status
        switch status
          when 202, 204
            context.respond status
          else
            context.respond status, result


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


