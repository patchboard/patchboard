assert = require("assert")
Testify = require "testify"

{api, partial_equal} = require("./helpers")
media_type = api.media_type

Patchboard = require("../patchboard")
service = new Patchboard.Service(api)
classifier = new Patchboard.Classifier(service)


class MockRequest

  constructor: ({@url, @method, @headers={}}) ->
    service.augment_request(@)


Testify.test "Classifier", (context) ->

  test_classification = (name, {request, result}) ->
    context.test name, ->
      request = new MockRequest(request)
      classification = classifier.classify(request)
      partial_equal(classification, result)

  test_classification "Action with response_schema",
    request:
      url: "http://gh-knockoff.com/plans"
      method: "GET"
      headers:
        "Accept": media_type("plan_list")
    result:
      resource_type: "plans", action_name: "list",


  test_classification "Action with request_schema and response_schema",
    request:
      url: "http://gh-knockoff.com/organizations"
      method: "POST"
      headers:
        "Content-Type": media_type("organization")
        "Accept": media_type("organization")
    result:
      resource_type: "organizations", action_name: "create"


  test_classification "URL with path capture",
    request:
      url: "http://gh-knockoff.com/organizations/smurf"
      method: "GET"
      headers:
        "Accept": media_type("organization")
    result:
      resource_type: "organization", action_name: "get",
      path: {id: "smurf"},


  test_classification "Action with authorization",
    request:
      url: "http://gh-knockoff.com/organizations/smurf"
      method: "DELETE"
      headers:
        # TODO: test for real base64
        "Authorization": "Basic Pyrzqxgl"
    result:
      resource_type: "organization", action_name: "delete"


  test_classification "Action with query",
    request:
      url: "http://gh-knockoff.com/organizations?q=smurf&limit=3"
      method: "GET"
      headers:
        "Accept": media_type("organization_list")
    result:
      resource_type: "organizations", action_name: "search"
      query: {q: "smurf", limit: "3"}


  # Test failures

  test_classification "failure to match Accept header",
    request:
      url: "http://gh-knockoff.com/plans"
      method: "GET"
      headers:
        "Accept": "bogus"
    result:
      error:
        status: 406,
        message: "Not Acceptable",
        description: "Problem with request"


  test_classification "failure to match Content-Type header",
    request:
      url: "http://gh-knockoff.com/organizations"
      method: "POST"
      headers:
        "Accept": media_type("organization")
        "Content-Type": "bogus"
    result:
      error:
        status: 415,
        message: "Unsupported Media Type",
        description: "Problem with request"


  test_classification "failure to match method",
    request:
      url: "http://gh-knockoff.com/organizations"
      method: "PUT"
      headers:
        "Content-Type": media_type("organization")
        "Accept": media_type("organization")
    result:
      error:
        status: 405,
        message: "Method Not Allowed",
        description: "Problem with request"



  test_classification "failure to match authorization scheme",
    request:
      url: "http://gh-knockoff.com/organizations/smurf"
      method: "PUT"
      headers:
        "Authorization": "Capability Pyrzqxgl"
    result:
      error:
        status: 401,
        message: "Unauthorized",
        description: "Problem with request"









