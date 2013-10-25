assert = require("assert")
Testify = require "testify"

patchboard_api = require "../src/server/patchboard_api"
{api, partial_equal} = require("./helpers")
media_type = api.media_type

{definitions} = api.schema
# `definitions` is the conventional place to put schemas,
# so we'll define fragment IDs by default
if definitions
  for name, schema of definitions
    schema.id ||= "##{name}"


JSCK = require "jsck"
jsck = new JSCK.draft3 patchboard_api.schema, api.schema
#console.log Object.keys(jsck.references)

Service = require "../src/server/service"
Classifier = require "../src/server/classifier"

classifier = new Classifier
  schema_manager: jsck
  resources: api.resources
  mappings: api.mappings


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

  return

  test_classification "Action with request_schema and response_schema",
    request:
      url: "http://gh-knockoff.com/organizations"
      method: "POST"
      headers:
        "Content-Type": media_type("organization")
        "Accept": media_type("organization")
    result:
      resource_type: "organizations", action_name: "create"



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









