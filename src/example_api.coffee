# Imaginary API of a GitHub knockoff

exports.type = type = (name) ->
  "application/vnd.gh-knockoff.#{name}+json"

exports.mappings =
  authenticated_user:
    path: "/user"
    resource: "user"
 
  user_search:
    path: "/user"
    resource: "user_search"
    query:
      match:
        required: true
        type: "string"
      limit:
        type: "integer"
      offset:
        type: "integer"
      sort:
        type: "string"
        enum: ["asc", "desc"]
 
  user:
    resource: "user"
    template: "/user/:login"

  repositories:
    resource: "repositories"
    description: "Repositories for the authenticated user"
    path: "/repos"
  
  user_repositories:
    resource: "repositories"
    template: "/user/:login/repos"
  
  repository:
    resource: "repository"
    template: "/repos/:login/:name"
  
  repo_search:
    resource: "repo_search"
    path: "/repos"
    query:
      match:
        required: true
        type: "string"
      limit:
        type: "integer"
      offset:
        type: "integer"
      sort:
        type: "string"
        enum: ["asc", "desc"]
 


exports.resources =

  user:
    actions:
      get:
        method: "GET"
        response:
          type: type "user"
          status: 200
      update:
        method: "PUT"
        request:
          type: type "user"
        response:
          type: type "user"
          status: 200

  user_search:
    actions:
      get:
        method: "GET"
        response:
          type: type "user_list"
          status: 200

  repository:
    actions:
      get:
        method: "GET"
        response:
          type: type "repository"
          status: 200

      update:
        method: "PUT"
        request:
          authorization: "API-Token"
        response:
          type: type "repository"
          status: 200

      delete:
        method: "DELETE"
        request:
          authorization: "API-Token"
        response:
          status: 204

  repo_search:
    actions:
      get:
        method: "GET"
        response:
          type: type "repository_list"
        response:
          status: 200

  repositories:
    actions:
      create:
        method: "POST"
        request:
          type: type "repository"
        response:
          status: 201

  ref:
    actions:
      get:
        method: "GET"
        response:
          type: type "reference"
          status: 200

  branch:
    actions:
      get:
        method: "GET"
        response:
          type: type "reference"
          status: 200
      delete:
        method: "DELETE"
        response:
          status: 204

  tag:
    actions:
      get:
        method: "GET"
        response:
          type: type "reference"
          status: 200
      delete:
        method: "DELETE"
        response:
          status: 204


exports.schema =
  id: "urn:gh-knockoff"
  # This is the conventional place to store schema definitions,
  # becoming official as of Draft 04
  definitions:

    resource:
      type: "object"
      properties:
        url:
          type: "string"
          format: "uri"

    user:
      extends: {$ref: "#/definitions/resource"}
      mediaType: type("user")
      properties:
        login: {type: "string"}
        name: {type: "string"}
        email: {type: "string"}

    user_list:
      mediaType: type("user_list")
      type: "array"
      items: {$ref: "#/definitions/user"}


    repository:
      extends: {$ref: "#/definitions/resource"}
      mediaType: type("repository")
      properties:
        name: {type: "string"}
        description: {type: "string"}
        refs:
          type: "object"
          properties:
            main: {$ref: "#/definitions/branch"}
            branches:
              type: "object"
              additionalProperties: {$ref: "#/definitions/branch"}
            tags:
              type: "array"
              items: {$ref: "#/definitions/tag"}

    repository_list:
      mediaType: type("repository_list")
      type: "array"
      items: {$ref: "#/definitions/repository"}


    reference:
      extends: {$ref: "#/definitions/resource"}
      mediaType: type("reference")
      properties:
        name:
          required: true
          type: "string"
        commit:
          required: true
          type: "string"
        message:
          required: true
          type: "string"

    branch:
      extends: {$ref: "#/definitions/reference"}
      mediaType: type("branch")

    tag:
      extends: {$ref: "#/definitions/reference"}
      mediaType: type("tag")



