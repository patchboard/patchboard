# Imaginary API of a GitHub knockoff

exports.media_type = media_type = (name) ->
  "application/vnd.gh-knockoff.#{name}+json;version=1.0"

exports.schema =
  id: "gh-knockoff"
  properties:

    resource:
      type: "object"
      properties:
        url:
          type: "string"
          format: "uri"

    organization:
      extends: {$ref: "#resource"}
      mediaType: media_type("organization")
      properties:
        name: {type: "string"}
        plan: {$ref: "#plan"}
        projects:
          # Here's how you describe a dictionary
          type: "object"
          additionalProperties: {$ref: "#project"}
        members: {$ref: "#user_list"}

    organization_list:
      type: "object"
      mediaType: media_type("organization_list")
      additionalProperties: {$ref: "#organization"}


    plan:
      extends: {$ref: "#resource"}
      mediaType: media_type("plan")
      properties:
        name: {type: "string"}
        space: {type: "integer"}
        bandwidth: {type: "integer"}

    plan_list:
      type: "object"
      mediaType: media_type("plan_list")
      additionalProperties: {$ref: "#plan"}

    user:
      extends: {$ref: "#resource"}
      mediaType: media_type("user")
      properties:
        name: {type: "string"}
        email: {type: "string"}

    user_list:
      mediaType: media_type("user_list")
      type: "array"
      items: {$ref: "#user"}


    project:
      extends: {$ref: "#resource"}
      mediaType: media_type("project")
      properties:
        name: {type: "string"}
        description: {type: "string"}
        refs:
          type: "object"
          properties:
            main: {$ref: "#branch"}
            branches:
              type: "object"
              additionalProperties: {$ref: "#branch"}
            tags:
              type: "array"
              items: {$ref: "#tag"}

    project_list:
      mediaType: media_type("project_list")
      type: "array"
      items: {$ref: "#project"}


    reference:
      extends: {$ref: "#resource"}
      mediaType: media_type("reference")
      properties:
        name: {type: "string"}
        commit: {type: "string"}
        message: {type: "string"}

    branch:
      extends: {$ref: "#reference"}
      mediaType: media_type("branch")

    tag:
      extends: {$ref: "#reference"}
      mediaType: media_type("tag")



exports.resources =

  organizations:
    actions:

      create:
        method: "POST"
        request_schema: "organization"
        response_schema: "organization"
        status: 201

      search:
        method: "GET"
        response_schema: "organization_list"
        query:
          q:
            required: true
            type: "string"
          limit:
            type: "integer"
          offset:
            type: "integer"
        status: 200

  organization:
    actions:
      get:
        method: "GET"
        response_schema: "organization"
        status: 200

      update:
        method: "PUT"
        request_schema: "organization"
        response_schema: "organization"
        authorization: "Basic"
        status: 200

      delete:
        method: "DELETE"
        authorization: "Basic"
        status: 204

  plans:
    actions:
      list:
        method: "GET"
        response_schema: "plan_list"
        status: 200


  plan:
    actions:
      get:
        method: "GET"
        response_schema: "plan"
        status: 200

      update:
        method: "PUT"
        request_schema: "plan"
        response_schema: "plan"
        status: 200

  user:
    actions:

      get:
        method: "GET"
        response_schema: "user"
        status: 200

      update:
        method: "GET"
        response_schema: "user"
        status: 200

  project:
    actions:

      get:
        method: "GET"
        response_schema: "project"
        status: 200

      update:
        method: "PUT"
        response_schema: "project"
        status: 200

      delete:
        method: "DELETE", status: 204

  ref:
    actions:
      get:
        method: "GET"
        response_schema: "reference"
        status: 200

  branch:
    actions:
      get:
        method: "GET"
        response_schema: "reference"
        status: 200
      rename:
        method: "POST"
        status: 200
      delete:
        method: "DELETE"
        status: 204

  tag:
    actions:
      get:
        method: "GET"
        response_schema: "reference"
        status: 200
      delete:
        method: "DELETE"
        status: 204

exports.service_url = "http://gh-knockoff.com/"

exports.paths =
  organizations:
    path: "/organizations"
    publish: true

  organization:
    path: "/organizations/:id"

  plans:
    path: "/plans"
    publish: true

  plan:
    path: "/plans/:id"

  user:
    path: "/users/:id"


