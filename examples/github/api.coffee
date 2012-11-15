SchemaManager = require("patchboard-client/schema_manager")
schema = require("./api/schema.coffee")
SchemaManager.normalize(schema)
service_url = "https://api.github.com"
module.exports =
  service_url: service_url
  directory: require("./api/directory")
  url_templates: require("./api/url_templates")(service_url)
  resources: require("./api/resources")
  schemas: [require("./api/schema")]
