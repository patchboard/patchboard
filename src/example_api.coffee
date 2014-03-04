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
 
  tag:
    resource: "tag"
    template: "/tags/:sha"

  branch:
    resource: "branch"
    template: "/branches/:name"


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
      extends: {$ref: "#resource"}
      mediaType: type("user")
      properties:
        login: {type: "string"}
        name: {type: "string"}
        email: {type: "string"}

    user_list:
      mediaType: type("user_list")
      type: "array"
      items: {$ref: "#user"}


    repository:
      extends: {$ref: "#resource"}
      mediaType: type("repository")
      properties:
        name: {type: "string"}
        description: {type: "string"}
        login: {type: "string"}
        owner: {$ref: "#user"}
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

    repository_list:
      mediaType: type("repository_list")
      type: "array"
      items: {$ref: "#repository"}


    reference:
      extends: {$ref: "#resource"}
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
      extends: {$ref: "#reference"}
      mediaType: type("branch")

    tag:
      extends: {$ref: "#reference"}
      mediaType: type("tag")

# Write out as JSON for non-Node clients
fs = require "fs"
path = "#{__dirname}/example_api.json"
fs.writeFileSync path, JSON.stringify(module.exports, null, 2)


