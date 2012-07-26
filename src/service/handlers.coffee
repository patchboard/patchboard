
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

module.exports = (service) ->

  meta:
    options: (context) ->
      {request, response, match} = context
      console.log "Options match data:", match

      allowed = match.allow.join(", ")
      response.writeHead 204,
        "Allow": allowed
        "Access-Control-Allow-Origin": "*"
        "Access-Control-Allow-Methods": allowed
        "Access-Control-Allow-Headers": "Content-Type, Accept"
        "Access-Control-Max-Age": 30 # seconds

        "Content-Length": 0
      response.end("")

    service_description: (context) ->
      {request, response, match} = context
      service_description =
        interface: service.interface
        schema: service.schema

      content = JSON.stringify(service_description)
      headers =
        "Content-Type": "application/json"
        "Content-Length": content.length
      response.writeHead 200, headers
      response.end(content)

    documentation: (context) ->
      {request, response, match} = context

      markdown = service.documentation()
      if /html/.test request.headers["accept"]
        content = html(marked(markdown))
        media_type = "text/html"
      else
        content = markdown
        media_type = "text/plain"

      context.respond 200, content,
        "Content-Type": media_type

    default: (context) ->
      {request, response, match} = context

      content = JSON.stringify
        message: "Unimplemented: #{match.resource_type}.#{match.action_name}"
      headers =
        "Content-Type": "application/json"
        "Content-Length": content.length
      response.writeHead 501, headers
      response.end(content)

