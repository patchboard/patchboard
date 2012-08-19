http = require("http")
marked = require("marked")
marked.setOptions
  gfm: true
  pedantic: false

class Documenter
  constructor: (@schemas, @resources) ->

  document_resources: () ->
    out = []
    out.push "# Resources"
    for name, definition of @resources
      out.push @resource_doc(name, definition)
    out.join("\n\n")

  resource_doc: (name, definition) ->
    lines = []
    lines.push "## #{name}"
    if definition.description
      lines.push definition.description
    for action_name, action_def of definition.actions
      lines.push @action_doc(action_name, action_def)
    lines.join("\n\n")

  action_doc: (name, definition) ->
    lines = []
    lines.push "### Action: `#{name}`"
    if definition.description
      lines.push definition.description
    lines.push "**HTTP Request**"
    lines.push "- **Method: `#{definition.method}`**"
    if definition.query?.required
      required = definition.query.required
      keys = Object.keys(required)
      if keys.length > 0
        lines.push "- **Required query parameters:** #{keys.join(', ')}"

    headers = []
    if definition.request_schema
      content_type = @schemas[definition.request_schema].mediaType
      headers.push "  - **Content-Type: `#{content_type}`**"
      re = definition.request_schema
    if definition.response_schema
      accept = @schemas[definition.response_schema].mediaType
      headers.push "  - **Accept: `#{accept}`**"
    if definition.authorization
      headers.push "  - **Authorization: `#{definition.authorization} <credential>`**"
    if headers.length > 0
      lines.push "- **Headers**"
      lines.push headers.join("\n\n")
      if definition.request_schema
        lines.push "- **Body Schema**: [#{re}](##{@schemas[re].id.replace("#", "/")})"

    lines.push "**HTTP Response**"
    if status = definition.status
      lines.push "- **Expected Status**: #{status} - #{http.STATUS_CODES[status]}"
    if definition.response_schema
      re = definition.response_schema
      lines.push "- **Body Schema**: [#{re}](##{@schemas[re].id.replace("#", "/")})"

    lines.join("\n\n")


module.exports = Documenter

