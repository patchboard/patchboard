lazyRequire = (path) -> get: (-> require( path )), enumerable: true

Object.defineProperties module.exports,
  Server: lazyRequire "./server"
  SimpleServer: lazyRequire "./simple_server"
  Service: lazyRequire "./service"
  SimpleDispatcher: lazyRequire "./dispatchers/simple"
  middleware: lazyRequire "./middleware"

