#!/usr/bin/env coffee
path = require("path")
fs = require("fs")

try
  file = process.argv[2]

  file = path.resolve(file)
  outfile = process.argv[3]

  obj = require(file)

  json = JSON.stringify(obj, null, 2)
  if outfile
    fs.writeFileSync(outfile, json)
  else
    console.log(json)
catch error
  console.log(error)
  console.log "Usage: c2json.coffee <path/to/coffee> [path/to/json]"

