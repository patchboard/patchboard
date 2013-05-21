assert = require("assert")
Testify = require "testify"

{api, partial_equal} = require("./helpers")
media_type = api.media_type

Patchboard = require("../patchboard")
service = new Patchboard.Service(api)
classifier = new Patchboard.Classifier(service)

class MockRequest

  constructor: ({@url, @method, @headers}) ->
    service.augment_request(@)


test_classification = (context, name, {request, result}) ->
  context.test name, ->
    request = new MockRequest(request)
    classification = classifier.classify(request)
    #console.log classification
    partial_equal(classification, result)

# http://www.w3.org/TR/cors/#resource-preflight-requests
Testify.test "Classification of CORS preflight OPTION requests", (context) ->

  context.test "negatives", (context) ->

    # 6.2.1
    test_classification context, "missing Origin header",
      request:
        url: "http://gh-knockoff.com/plans"
        method: "OPTIONS"
        headers: {}
      result:
        resource_type: "meta", action_name: "options",
        allow: [ "GET" ]

    # 6.2.3a
    test_classification context, "missing request-method header",
      request:
        url: "http://gh-knockoff.com/plans"
        method: "OPTIONS"
        headers:
          "Origin": "http://smurf.com"
      result:
        resource_type: "meta", action_name: "options",
        allow: [ "GET" ]

    # 6.2.3b
    test_classification context, "request-method header specifies unusable method",
      request:
        url: "http://gh-knockoff.com/plans"
        method: "OPTIONS"
        headers:
          "Origin": "http://smurf.com"
          "Access-Control-Request-Method": "PUT"
      result:
        resource_type: "meta", action_name: "options",
        allow: [ "GET" ]


  context.test "positives", (context) ->

    test_classification context, "CORS preflight request",
      request:
        url: "http://gh-knockoff.com/organizations/smurf"
        method: "OPTIONS"
        headers:
          "Origin": "http://smurf.com"
          "Access-Control-Request-Method": "PUT"
      result:
        resource_type: "meta", action_name: "preflight",
        allow: [ "DELETE", "GET", "PUT" ]


    test_classification context, "path with query",
      request:
        url: "http://gh-knockoff.com/organizations?q=smurf&limit=3"
        method: "OPTIONS"
        headers:
          "Origin": "http://smurf.com"
          "Access-Control-Request-Method": "GET"
      result:
        resource_type: "meta", action_name: "preflight"
        allow: [ "GET", "POST" ]

