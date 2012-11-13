patchboard_schema = require("../../server/coffee/src/patchboard_api").schema
module.exports =
  service_url: "https://api.github.com"
  directory: require("./api/directory.coffee")
  resources: require("./api/interface.coffee")
  schemas: [require("./api/schema.coffee")]
