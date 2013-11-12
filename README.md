# Patchboard

Patchboard streamlines the development of REST API services by using a serializable API definition that is easy to write and easy to read. With it, you can eliminate the repetition and brittleness involved in writing and maintaining an API provided a server and used by clients in multiple languages.

Given a description of your URLs, resources, and schemas, Patchboard provides a Node.js server that validates HTTP requests and dispatches them to resource handlers you define.  The server exposes the API Definition as JSON, which a Patchboard client can use to self-assemble the logic needed to interact with the API.

Because the API Definition is serializable, Patchboard clients that consume it at runtime can be implemented in any sufficiently dynamic language.  At this time, only a [JavaScript client][patchboard-js] has been written.


## API Definition format

Examples are excerpts from the [Trivial example][patchboard-trivial], which is written in CoffeeScript.

### Mappings

A dictionary that maps arbitrary logical names to resources and the URLs used to access them.

```.coffee

module.exports =

  users:
    resource: "users"
    path: "/users"

  user_search:
    resource: "user"
    path: "/user"
    query:
      login:
        required: true
        type: "string"

  user:
    resource: "user"
    template: "/users/:id"
```

### Schemas

A JSON Schema (currently limited to [draft 3][json-schema-3]) describing the data structures used by an API. Resource schemas are defined as properties of the top level `definitions` field.  


```.coffee

media_type = (name) ->
  "application/vnd.trivial.#{name}+json;version=1.0"

module.exports =

  id: "urn:patchboard.trivial"
  definitions:

    resource:
      extends: {$ref: "urn:patchboard#resource"}

    user:
      extends: {$ref: "#resource"}
      mediaType: media_type "user"
      properties:
        login:
          required: true
          type: "string"
          pattern: "^[a-zA-z0-9_.]{3,32}"
        email:
          type: "string"
          format: "email"
        password:
          type: "string"
          minLength: 4
          maxLength: 64
        questions: {$ref: "#questions"}
```


### Resources

A dictionary describing the resources provided by the API.  Each top level field defines a resource.

An excerpt of the Trivial example:

```.coffee

type = (name) ->
  "application/vnd.trivial.#{name}+json;version=1.0"

module.exports =
  users:
    actions:
      create:
        method: "POST"
        request:
          type: type "user"
        response:
          type: type "user"
          status: 201

  user_search:
    actions:
      get:
        method: "GET"
        response:
          type: type "user"
          status: 200

  user:
    actions:
      get:
        method: "GET"
        response:
          type: type "user"
          status: 200
      delete:
        method: "DELETE"
        response:
          status: 204
```

For each resource, the `actions` dictionary defines the available actions, specifying the HTTP method, the request and/or response media types, and the status that signifies a successful response.


## Implementing a Patchboard Service

## Validate your definition

Patchboard includes a [JSON Schema][patchboard-def-schema] that describes a valid API Definition. A convenient way to validate your definition is to use `bin/patchboard`.

    bin/patchboard validate path/to/api.json # or api.coffee, or api.js

You can also print a basic example definition to STDOUT.

    bin/patchboard example json # or cson


### Patchboard.Server

```coffee
Patchboard = require "patchboard"
api = require "./api"
handlers = require "./handlers"

server = new Patchboard.Server api,
  # Host and port to listen for HTTP requests
  host: "127.0.0.1", port: 1979
  # The base URL for resources
  url: "http://localhost:1979/"
  handlers: handlers

```

### Request Handlers

The request handler object is a dictionary of dictionaries.  The top level fields correspond to resource names, with the fields in the values mapping to actions.  For each resource + action, you define a function which takes a request [Context](#request-context) object as its argument.

In the following simplified example, the module exports a function which takes an application instance as its argument, then returns the handlers dictionary.

```coffee
module.exports = (application) ->

  users:
    create: (context) ->
      {match, request} = context
      content = request.body
      application.create_user content, (error, result) -> 
        if error
          context.error error.name, error.message
        else
          context.respond match.success_status, result

  user:
    get: (context) ->
      application.get_user context.match.path.id, (error, result) ->
        if error
          context.error error.name, error.message
        else
          context.respond match.success_status, result
    update: (context) ->
      {match, request} = context
      id = match.path.id
      content = request.body
      application.update_user id, content, (error, result) ->
        if error
          context.error error.name, error.message
        else
          context.respond match.success_status, result

```

Note that the callback passed to the application methods could easily be refactored into a function and used as the default for simple actions.

### Request Context

The default Patchboard dispatcher calls handler functions with an instance of Context as an argument.  Contexts bundle together the objects representing the HTTP request and response, as well as providing helper functions such as `respond` and `error`


## Using a Patchboard Client

Example use of the JavaScript client (in CoffeeScript).

```coffee
Client = require("patchboard").Client
# or you can require "patchboard-js" directly

# retrieve the API Definition from a Patchboard server and assemble a client.
Client.discover "http://localhost:1979/", (error, client) ->
  throw error if error
  
  client.resources.users.create {login: "matthew"}, (error, response) ->
    throw error if error

    user = response.resource
    user.update {email: "matthew@mail.com"}, (error, response) ->

```


[patchboard-js]:https://github.com/automatthew/patchboard-js
[json-schema-3]:http://tools.ietf.org/html/draft-zyp-json-schema-03
[patchboard-trivial]:https://github.com/automatthew/patchboard-examples/tree/master/trivial
[patchboard-def-schema]:https://github.com/automatthew/patchboard/blob/master/schema.json

