#!/usr/bin/env coffee
[interpreter, script, api_file, port] = process.argv

path = require("path")
fs = require("fs")

connect = require("connect")

api_file ||= "api.coffee"
api_file = path.resolve(api_file)
if fs.existsSync(api_file)
  api = require(api_file)
  #string = fs.readFileSync(api_file)
  #api = JSON.parse(string)
else
  throw "API spec missing: #{api_file}"

Patchboard = require "../src/patchboard"

service = new Patchboard.Service(api)

# service.simple_dispatcher returns the http handler function
# used by Connect or the stdlib http server.
dispatcher = service.simple_dispatcher({})

@app = connect()
@app.use(connect.compress())
@app.use(Patchboard.middleware.json())
@app.use(dispatcher)


port ||= 1338
console.log("HTTP server listening on port #{port}")
@app.listen(port)


