SchemaManager = require("patchboard-client/schema_manager")
schema = require("./api/schema.coffee")
SchemaManager.normalize(schema)
module.exports =
  service_url: "https://api.github.com"
  directory: require("./api/directory.coffee")
  resources: require("./api/interface.coffee")
  schemas: [require("./api/schema.coffee")]
