assert = require("assert")
helpers = require("./helpers")
testify = require("../src/testify")
patchboard_api = require("../src/patchboard_api")
SchemaManager = require("../src/schema_manager")

schemas = []

patchboard_api.schema

app_schema =
  id: "not_a_uri"
  properties:
    resource:
      extends: {$ref: "patchboard#resource"}


testify "schema normalization", ->
  result = SchemaManager.normalize(patchboard_api.schema)
  assert.equal(patchboard_api.schema.id, "urn:json:patchboard")

#manager = new SchemaManager(schemas...)


