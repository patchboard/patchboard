lazyRequire = (path) -> get: (-> require( path )), enumerable: true

Object.defineProperties module.exports,
  Server: lazyRequire "patchboard-server"
  Client: lazyRequire "patchboard-client"
  Tools: lazyRequire "./tools"

