assert = require("assert")

helpers = require("./helpers")
test = helpers.test
client_interface = helpers.interface
schema = helpers.schema


Documenter = require("patchboard/src/service/documenter")

documenter = new Documenter(helpers.schema, helpers.interface)
console.log documenter.document_interface()
