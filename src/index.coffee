lazyRequire = (path) -> get: (-> require( path )), enumerable: true

Object.defineProperties module.exports,
  Server: lazyRequire "./server"
  Service: lazyRequire "./server/service"
  middleware: lazyRequire "./server/middleware"
  Tools: lazyRequire "./tools"

