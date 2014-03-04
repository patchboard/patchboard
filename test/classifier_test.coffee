assert = require("assert")
Testify = require "testify"

Service = require "../src/server/service"


{augment_request} = require("../src/server/util")
{api, partial_equal} = require("./helpers")

{type, resources, mappings} = api
service = new Service api,
  url: "http://api.wherever.com"
  validate: false
  log:
    debug: ->
    info: ->
    warn: ->
    error: (error) -> console.error error

classifier = service.classifier

class MockRequest

  constructor: ({@url, @method, @headers}) ->
    @headers ||= {}
    augment_request(@)


Testify.test "Classifier", (context) ->

  test_classification = (name, {request, result}) ->
    context.test name, ->
      request = new MockRequest(request)
      match = classifier.classify(request)
      partial_equal(match, result)

  test_classification "simple URL, response schema",
    request:
      url: "http://api.wherever.com/user"
      method: "GET"
      headers:
        "Accept": type("user")
    result:
      resource_type: "authenticated_user", action_name: "get",

  test_classification "URL with path capture, response schema",
    request:
      url: "http://api.wherever.com/user/dyoder"
      method: "GET"
      headers:
        "Accept": type("user")
    result:
      resource_type: "user", action_name: "get",

  test_classification "Simple URL, request_schema and response_schema",
    request:
      url: "http://api.wherever.com/user"
      method: "PUT"
      headers:
        "Content-Type": type("user")
        "Accept": type("user")

    result:
      resource_type: "authenticated_user", action_name: "update"


  test_classification "Action with query",
    request:
      url: "http://api.wherever.com/user?match=smurf&limit=3"
      method: "GET"
      headers:
        "Accept": type("user_list")
    result:
      resource_type: "user_search", action_name: "get"
      query: {match: "smurf", limit: "3"}


  # Test failures


  test_classification "failure to match Accept header",
    request:
      url: "http://api.wherever.com/user/dyoder"
      method: "GET"
      headers:
        "Accept": "bogus"
    result:
      error:
        status: 406,
        message: "Not Acceptable",
        reason: "Problem with request"


  test_classification "failure to match Content-Type header",
    request:
      url: "http://api.wherever.com/user"
      method: "PUT"
      headers:
        "Accept": type("user")
        "Content-Type": "bogus"
    result:
      error:
        status: 415,
        message: "Unsupported Media Type",
        reason: "Problem with request"


  test_classification "failure to match method",
    request:
      url: "http://api.wherever.com/repos"
      method: "PUT"
      headers:
        "Content-Type": type("repository")
        "Accept": type("repository")
    result:
      error:
        status: 405,
        message: "Method Not Allowed",
        reason: "Problem with request"


  test_classification "Action with authorization",
    request:
      url: "http://api.wherever.com/repos/dyoder/smurf"
      method: "DELETE"
      headers:
        # TODO: test for real base64
        "Authorization": "API-Token Pyrzqxgl"
    result:
      resource_type: "repository", action_name: "delete"


  test_classification "failure to match authorization scheme",
    request:
      url: "http://api.wherever.com/repos/dyoder/smurf"
      method: "PUT"
      headers:
        "Authorization": "Capability Pyrzqxgl"
        "Content-Type": type "repository"
        "Accept": type "repository"
    result:
      error:
        status: 401,
        message: "Unauthorized",
        reason: "Problem with request"









