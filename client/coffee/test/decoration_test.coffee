assert = require "assert"
Testify = require "testify"

Client = require "../client"

{api} = require "./helpers"

client = new Client(api)


schema = client.schema_manager.find "organization"
organization = client.decorate schema,
  name: "pandastrike"
  url: "http://test.com/pandastrike"
  # for testing a resource as a top level property
  plan:
    url: "http://test.com/super_plan"
    name: "Super"
    space: 400
    bandwidth: 1000
  # for testing resources in an array
  members: [
    {name: "dan", email: "dan@pandastrike.com", url: "http://test.com/dan"}
    {name: "lance", email: "lance@pandastrike.com", url: "http://test.com/lance"}
    {name: "matthew", email: "matthew@pandastrike.com", url: "http://test.com/matthew"},
  ]
  # for testing dictionaries
  projects:
    fate:
      url: "http://test.com/fate"
      name: "Fate"
      description: "Multi-process control for dev/testing"
      # for testing a sub-object with resources as defined properties
      refs:
        main:
          name: "master", ref: "81ccdbb", message: "fixed bug"

        branches:
          master:
            name: "master"
            ref: "81ccdbb"
            message: "fixed bug"
          experiment:
            name: "experiment"
            ref: "b9f2198"
            message: "secret experiment"
          "22-readline":
            name: "22-readline"
            ref: "4385a49"
            message: "Partially working tab completion"
        tags: [
          {name: "0.2.1", ref: "c144855a", message: "Release 0.2.1"}
        ]
    ark:
      url: "http://test.com/ark"
      name: "Ark"
      description: "Javascript module packaging"
      refs:
        main:
          name: "master", ref: "41fceb1", message: "Fixed #2 - nothing working"
        branches: {}
        tags: []


assert_properties = (object, names) ->
  for name in names
    assert.ok object[name]

assert_resource = (object) ->
  assert.ok object.constructor != Object

assert_actions = (object, names) ->
  for name in names
    assert.equal typeof(object[name]), "function"

# TODO: see if JSV is a better solution for verifying we aren't destroying
# data, as we are using a JSON schema after all.

Testify.test "Resource decoration", (context) ->

  context.test "Main object", (context) ->
    context.test "has correct properties", ->
      assert_properties organization, ["name", "members", "plan", "projects"]
    context.test "has correct constructor", ->
      assert_resource organization
    context.test "has expected action methods", ->
      assert_actions organization, ["get"]

  context.test "An object as top level property", (context) ->
    object = organization.plan
    context.test "has correct properties", ->
      assert_properties object, ["name", "space", "bandwidth"]
    context.test "has correct constructor", ->
      assert_resource object
    context.test "has expected action methods", ->
      assert_actions object, ["get", "update"]

  context.test "Items in array", (context) ->
    array = organization.members
    context.test "have correct properties", ->
      for item in array
        assert_properties item, ["name", "email"]
    context.test "have correct constructor", ->
      for item in array
        assert_resource item
    context.test "have expected action methods", ->
      for item in array
        assert_actions item, ["get", "update"]

  context.test "Resources in a dictionary", (context) ->
    projects = organization.projects
    context.test "have correct properties", ->
      assert.ok projects.fate
      assert.ok projects.ark
      for name, project of projects
        assert_properties project, ["name", "description", "refs"]
        assert_properties project.refs, ["main", "branches", "tags"]
    context.test "have correct constructor", ->
      for name, project of organization.projects
        assert_resource project
    context.test "have expected action methods", ->
      for name, project of organization.projects
        assert_actions project, ["get", "update", "delete"]


  context.test "In a deeply nested object", (context) ->
    context.test "a resource as a defined property", (context) ->
      main = organization.projects.fate.refs.main
      context.test "has correct properties", ->
        assert_properties main, ["name", "ref", "message"]
      context.test "has correct constructor", ->
        assert_resource main
      context.test "has expected action methods", ->
        assert_actions main, ["get"]

    context.test "resources as items in a dict", (context) ->
      branches = organization.projects.fate.refs.branches
      context.test "have correct properties", ->
        for name, branch of branches
          assert_properties branch, ["name", "ref", "message"]
      context.test "have correct constructor", ->
        for name, branch of branches
          assert_resource branch
      context.test "have expected action methods", ->
        for name, branch of branches
          assert_actions branch, ["get", "rename", "delete"]


    context.test "resources as items in an array", (context) ->
      tags = organization.projects.fate.refs.tags
      context.test "have correct properties", ->
        for tag in tags
          assert_properties tag, ["name", "ref", "message"]
      context.test "have correct constructor", ->
        for tag in tags
          assert_resource tag
      context.test "have expected action methods", ->
        for tag in tags
          assert_actions tag, ["get", "delete"]


