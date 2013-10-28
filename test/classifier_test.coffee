assert = require("assert")
Testify = require "testify"

Service = require "../src/server/service"
Classifier = require "../src/server/classifier"
SchemaManager = require "../src/server/schema_manager2"

{api, partial_equal} = require("./helpers")
{media_type, resources, mappings} = api
schema_manager = new SchemaManager api.schema
classifier = new Classifier {schema_manager, resources, mappings}


class MockRequest

  constructor: ({@url, @method, @headers}) ->
    @headers ||= {}
    Service.augment_request(@)


Testify.test "Classifier", (context) ->

  test_classification = (name, {request, result}) ->
    context.test name, ->
      request = new MockRequest(request)
      classification = classifier.classify(request)
      partial_equal(classification, result)

  test_classification "simple URL, response schema",
    request:
      url: "http://gh-knockoff.com/user"
      method: "GET"
      headers:
        "Accept": media_type("user")
    result:
      resource_type: "authenticated_user", action_name: "get",

  test_classification "URL with path capture, response schema",
    request:
      url: "http://gh-knockoff.com/user/dyoder"
      method: "GET"
      headers:
        "Accept": media_type("user")
    result:
      resource_type: "user", action_name: "get",


  test_classification "Simple URL, request_schema and response_schema",
    request:
      url: "http://gh-knockoff.com/user"
      method: "PUT"
      headers:
        "Content-Type": media_type("user")
        "Accept": media_type("user")
    result:
      resource_type: "authenticated_user", action_name: "update"

  test_classification "Action with query",
    request:
      url: "http://gh-knockoff.com/user?match=smurf&limit=3"
      method: "GET"
      headers:
        "Accept": media_type("user_list")
    result:
      resource_type: "user_search", action_name: "get"
      query: {match: "smurf", limit: "3"}

  return

  #test_classification "Action with authorization",
    #request:
      #url: "http://gh-knockoff.com/organizations/smurf"
      #method: "DELETE"
      #headers:
        ## TODO: test for real base64
        #"Authorization": "Basic Pyrzqxgl"
    #result:
      #resource_type: "organization", action_name: "delete"



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









