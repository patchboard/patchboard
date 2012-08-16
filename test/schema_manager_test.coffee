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
  #console.log JSON.stringify(patchboard_api.schema, null, 2)
  console.log JSON.stringify(result, null, 2)
  assert.equal(patchboard_api.schema.id, "urn:json:patchboard")

#manager = new SchemaManager(schemas...)

#console.log sm.document()

#testify "schema normalization", ->
  #assert.ok sm.get_schema("#account")
  #assert.ok sm.get_schema("spire#account")
  #assert.ok sm.get_schema("patchboard#resource")


