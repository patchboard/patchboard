
marked = require("marked")

html = (input) ->
  """
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <title>API Documentation</title>

      <style type="text/css">
        body { padding: 1em; }
      </style>
    </head>
    <body>
      #{input}
    </body>
  </html>
  """

# Default action handlers.  You can override these in applications.
module.exports = (service) ->

  # the "meta" handlers do not correspond to actual resource/action requests
  # made by clients.  They are to be used for weird situations like OPTIONS.
  meta:
    options: (context) ->
      {request, response, match} = context
      allowed = match.allow.join(", ")
      context.respond 204, "",
        "Allow": allowed

    # The default handler for CORS preflight requests.  You will probably want to
    # override this handler.  See:
    # http://www.w3.org/TR/cors/#resource-preflight-requests
    preflight: (context) ->
      {request, response, match} = context
      allowed = match.allow.join(", ")
      context.respond 204, "",
        "Allow": allowed
        "Access-Control-Allow-Origin": request.headers["Origin"]
        "Access-Control-Allow-Methods": allowed
        "Access-Control-Allow-Headers": "Content-Type, Accept"
        "Access-Control-Max-Age": 30 # seconds

  service:
    description: (context) ->
      {request, response, match} = context

      context.set_cors_headers("*")
      content = JSON.stringify(service.description, null, 2)
      context.respond 200, content,
        "Content-Type": "application/json"

    documentation: (context) ->
      {request, response, match} = context

      markdown = service.documentation()
      if /html/.test request.headers["accept"]
        content = html(marked(markdown))
        media_type = "text/html"
      else
        content = markdown
        media_type = "text/plain"

      context.set_cors_headers("*")
      context.respond 200, content,
        "Content-Type": media_type

    default: (context) ->
      {request, response, match} = context

      content = JSON.stringify
        message: "Unimplemented: #{match.resource_type}.#{match.action_name}"
      context.set_cors_headers("*")
      context.respond 501, content,
        "Content-Type": "application/json"
        "Content-Length": content.length

