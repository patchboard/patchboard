assert = require("assert")

helpers = require("./helpers")
testify = require("../src/testify")

api = require("./sample_api.coffee")
Patchboard = require("../src/patchboard")
service = new Patchboard.Service(api)
classifier = new Patchboard.Classifier(service)


class MockRequest

  constructor: (options) ->
    @url = options.url
    @method = options.method
    @headers = options.headers
    service.improve_request(@)


test_classification = (name, want, options) ->
  testify name, ->
    request = new MockRequest(options)
    result = classifier.classify(request)
    helpers.partial_equal(result, want)

test_classification "Action with Accept",
  {
    resource_type: "resource_collection", action_name: "list"
  },
  url: "http://hostname.com/resource"
  method: "GET"
  headers:
    "Accept": "patchboard.resource_collection"

test_classification "Action with Content-Type and Accept",
  {
    resource_type: "resource_collection", action_name: "create"
  },
  url: "http://hostname.com/resource"
  method: "POST"
  headers:
    "Content-Type": "patchboard.resource_instance"
    "Accept": "patchboard.resource_instance"

test_classification "Action with path capture",
  {
    resource_type: "resource_instance", action_name: "get",
    path: {id: "monkey"},
    accept: "patchboard.resource_instance"
  },
  url: "http://hostname.com/resource/monkey"
  method: "GET"
  headers:
    "Accept": "patchboard.resource_instance"

test_classification "Action with Authorization",
  {
    resource_type: "resource_instance", action_name: "delete"
  },
  url: "http://hostname.com/resource/monkey"
  method: "DELETE"
  headers:
    "Authorization": "Basic Pyrzqxgl"


test_classification "Action with query",
  {
    resource_type: "resource_collection", action_name: "search"
  },
  url: "http://hostname.com/resource?name=monk"
  method: "GET"
  headers:
    "Accept": "patchboard.resource_collection"

# Test failures


test_classification "failure to match Accept header",
  {
    error: {
      status: 406,
      message: "Not Acceptable",
      description: "Problem with request"
    }
  },
  url: "http://hostname.com/resource/monkey"
  method: "GET"
  headers:
    "Accept": "bogus"

test_classification "failure to match Content-Type header",
  {
    error: {
      status: 415,
      message: "Unsupported Media Type",
      description: "Problem with request"
    }
  },
  url: "http://hostname.com/resource"
  method: "POST"
  headers:
    "Accept": "patchboard.resource_instance"
    "Content-Type": "bogus"

test_classification "failure to match method",
  {
    error: {
      status: 405,
      message: "Method Not Allowed",
      description: "Problem with request"
    }
  },
  url: "http://hostname.com/resource/monkey"
  method: "PUT"
  headers:
    "Content-Type": "patchboard.resource_instance"
    "Accept": "patchboard.resource_instance"


test_classification "failure to match authorization scheme",
  {
    error: {
      status: 401,
      message: "Unauthorized",
      description: "Problem with request"
    }
  },
  url: "http://hostname.com/resource/monkey"
  method: "DELETE"
  headers:
    "Authorization": "Capability Pyrzqxgl"









