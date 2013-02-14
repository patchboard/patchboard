path = require("path")
fs = require("fs")

js2coffee = require("js2coffee")
JSV = require("JSV").JSV
jsv = JSV.createEnvironment("json-schema-draft-03")

schema = require("./schema")

example =
  paths:
    things:
      path: "/things"
      publish: true

  resources:
    things:
      actions:
        list:
          method: "GET"
          query:
            sort:
              type: "string"
              enum: ["asc", "desc"]
          response_schema: "foo_list"

  schema:
    id: "patchboard.example"
    thing:
      type: "object"
      properties:
        name:
          type: "string"
          required: true
    thing_list:
      type: "array"
      items: {$ref: "#thing"}

    
module.exports =

  validate: (api_file) ->
    api_file = path.resolve(api_file)
    try
      api = require(api_file)
      report = jsv.validate api, schema
      if report.errors.length == 0
        console.log "Valid API definition"
      else
        # TODO: provide more useful output, perhaps by finding and printing
        # the exact objects in the data and schema that are failing.
        # JSV may have some useful functions for this.
        console.log "Invalid API.  Errors:", report.errors
    catch error
      console.log "Problem reading API description:", error.message

  generate: (type) ->
    if type == "json"
      api = example
      string = JSON.stringify(api, null, 2)
      fs.writeFileSync("api.json", string)
    else if type == "coffee"
      api = example
      src = "modules.export = #{JSON.stringify(api)}"
      string = js2coffee.build(src)
      fs.writeFileSync("api.coffee", string)
    else
      console.log "Unsupported type: #{type}"

