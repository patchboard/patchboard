JSCK = require("jsck").draft3

api_def_schema = require("./schema")
jsck = new JSCK api_def_schema

validate = (api) ->
  report = validate_schema(api)
  if report.valid == false
    output =
      valid: false
      errors: []
        
    for error in report.errors
      output.errors.push
        type: "API format validation"
        document: error.document
        schema: error.schema
    return output

  output = {valid: true, errors: []}
  report = validate_mappings(api)
  if report.valid == false
    output.valid = false
    output.errors = output.errors.concat(report.errors)

  report = validate_resources(api)
  if report.valid == false
    output.valid = false
    output.errors = output.errors.concat(report.errors)

  report = validate_schemas(api)
  if report.valid == false
    output.valid = false
    output.errors = output.errors.concat(report.errors)

  return output

      

validate_schema = (api) ->
  jsck.validator("urn:patchboard.api#").validate(api)

validate_mappings = ({mappings, resources}) ->
  # TODO: report resources for which there are no mappings
  report =
    valid: true
    errors: []
  for name, definition of mappings
    {url, path, template} = definition
    if !(url? || path? || template?)
      report.valid = false
      report.errors.push
        type: "Mapping definition"
        location: "mappings.#{name}"
        reason: "Must define one of 'url', 'path', or 'template'"


    if path? && path.indexOf(":") != -1
      report.valid = false
      report.errors.push
        type: "Mapping definition"
        location: "mappings.#{name}"
        reason: """
          The value for 'path' contains parameters. \
          This should probably be a 'template'.
        """

    if template? && template.indexOf(":") == -1
      report.valid = false
      report.errors.push
        type: "Mapping definition"
        location: "mappings.#{name}"
        reason: """
          The value for 'template' contains no parameters. \
          this should probably be a 'path'.
        """

    resource_name = definition.resource
    if !resources[resource_name]?
      report.valid = false
      report.errors.push
        type: "Mapping reference"
        location: "mappings.#{name}"
        reason: "No such resource: '#{resource_name}'"

  return report


validate_resources = ({resources, schema}) ->
  report =
    valid: true
    errors: []
  for resource_name, {actions} of resources
    for action_name, {method, request, response} of actions
      media_types = {}
      for name, {mediaType} of schema.definitions
        if mediaType?
          media_types[mediaType] = true

      if request?.type?
        if !media_types[request.type]?
          report.valid = false
          report.errors.push
            type: "Action definition"
            location: "resources.#{resource_name}.actions.#{action_name}"
            reason: """
              Action specifies a request.type that is not defined in the schema.
            """
      if response?.type?
        if !media_types[response.type]?
          report.valid = false
          report.errors.push
            type: "Action definition"
            location: "resources.#{resource_name}.actions.#{action_name}"
            reason: """
              Action specifies a response.type that is not defined in the schema.
            """

      if response?.status == 204 && response.type?
        report.valid = false
        report.errors.push
          type: "Action definition"
          location: "resources.#{resource_name}.actions.#{action_name}"
          reason: """
            Expected status is 204 No Content, but the action defines a response type.
          """
  return report


validate_schemas = (api) ->
  report =
    valid: true
    errors: []

  for name, schema of api.schema.definitions
    if schema.extends?.$ref?
      if /#resource$/.test(schema.extends.$ref) && !schema.mediaType?
        report.valid = false
        report.errors.push
          type: "Schema definition"
          location: "schema.definitions.#{name}"
          reason: """
            Schema defines a resource (as signified by 'extends') but does not \
            define 'mediaType', which is required for references in the \
            resource definitions.
          """

  return report

module.exports = validate

