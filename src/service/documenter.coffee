marked = require("marked")
marked.setOptions
  gfm: true
  pedantic: false

class Documenter
  constructor: (schema, @interface) ->
    @schema_id = schema.id
    @schemas = schema.properties

  document_schema: () ->
    out = []
    out.push "# Schemas"
    for name, schema of @schemas
      out.push @schema_doc(name, schema)
    out.join("\n\n")

  schema_doc: (name, schema) ->
    lines = []
    lines.push """
    <a id="#{@schema_id}/#{name}"></a>
    ## #{name} 
    """
    lines.push """
    ```json
    #{JSON.stringify(schema, null, 2)}
    ```
    """
    lines.join("\n\n")


  document_interface: () ->
    out = []
    out.push "# Resources"
    for name, definition of @interface
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
    if definition.request_entity
      content_type = @schemas[definition.request_entity].mediaType
      headers.push "  - **Content-Type: `#{content_type}`**"
      re = definition.request_entity
    if definition.response_entity
      accept = @schemas[definition.response_entity].mediaType
      headers.push "  - **Accept: `#{accept}`**"
    if definition.authorization
      headers.push "  - **Authorization: `#{definition.authorization} <credential>`**"
    if headers.length > 0
      lines.push "- **Headers**"
      lines.push headers.join("\n\n")
      if definition.request_entity
        lines.push "- **Body Schema**: [#{re}](##{@schema_id}/#{re})"

    lines.push "**HTTP Response**"
    if definition.status
      lines.push "- **Expected Status**: #{definition.status}"
    if definition.response_entity
      re = definition.response_entity
      lines.push "- **Body Schema**: [#{re}](##{@schema_id}/#{re})"

    lines.join("\n\n")


module.exports = Documenter

