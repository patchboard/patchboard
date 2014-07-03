lazyRequire = (path) -> get: (-> require( path )), enumerable: true

Object.defineProperties module.exports,
  Server: lazyRequire "./server"
  Service: lazyRequire "./service"
  middleware: lazyRequire "./middleware"

