assert = require("assert")

helpers = require("./helpers")
test = helpers.test
util = require("util")


#fs = require("fs")
#string = fs.readFileSync("examples/spire/resource_schema.json")
#schemas = JSON.parse(string)
schemas = require("../examples/spire/resource_schema")


app_schema =
  id: "spire"
  properties:

    capability:
      id: "#capability"
      type: "string"

    capability_dictionary:
      id: "#capability_dictionary"
      type: "object"
      additionalProperties: {$ref: "spire#capability"}

    resource:
      id: "#resource"
      extends: {$ref: "rigger#resource"}
      properties:
        capabilities:
          $ref: "spire#capability_dictionary"

    account:
      id: "#account"
      mediaType: "application/vnd.spire-io.account+json;version=1.0"
      extends: {$ref: "spire#resource"}
      properties:
        id: {type: "string", readonly: true}
        secret: {type: "string", readonly: true}
        created_at: {type: "number", readonly: true}
        email: {type: "string", required: true}
        password: {type: "string", required: true}
        name: {type: "string"}

    session:
      id: "#session"
      media_type: "application/vnd.spire-io.session+json;version=1.0"
      extends: {$ref: "resource"}
      properties:
        resources:
          type: "object"
          properties:
            account: {$ref: "spire#account"}
            channels: {$ref: "spire#channel_collection"}
            applications: {$ref: "object"}
            subscriptions: {$ref: "spire#subscription_collection"}
            notifications: {$ref: "object"}


primitives =
  "string": true
  "object": true
  "array": true
  "boolean": true
  "number": true


convert_types = (schema) ->
  for key, value in schema.properties
    if value.type && !primitive[value.type]
      schema[key] = {$ref: "spire##{value.type}"}

t = {}
t.id = "spire"
t.properties = {}

for name, schema of schemas
  trans = { id: "##{name}"}
  if extender = schema.extends
    delete schema.extends
    if extender.indexOf("rigger#") == 0
      trans.extends = {$ref: extender}
    else
      trans.extends = {$ref: "spire##{extender}"}
  required = schema.required
  delete schema.required

  if schema.media_type
    trans.mediaType = schema.media_type
    delete schema.media_type
  for key, value of schema
    trans[key] = value
  if required
    for key in required
      trans.properties[key].required = true
  t.properties[name] = trans

#console.log(JSON.stringify(t.properties.account, null, 2))
#assert.deepEqual(t.properties.account, app_schema.properties.account)
console.log(JSON.stringify(t.properties.session, null, 2))
assert.deepEqual(t.properties.session, app_schema.properties.session)

process.exit()


