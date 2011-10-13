var http = require("http"),
    path = require("path"),
    url = require("url");

var Connector = exports.Connector = require("./quern/connector");

var App = exports.App = function App (options) {
  options = options || {};
  this.logDirectory = options.logDirectory || "logs";
  this.host = options.host || "127.0.0.1";
  this.port = options.port || 5440;
  this.timeout = options.timeout || 60 * 1000; // in ms.
  this.connectors = options.connectors || [];
};

App.prototype.run = function (options) {
  var server = http.createServer(this.handler());
  server.listen(this.port, this.host);
  console.log("Server running at http://"+this.host+":"+this.port+"/");
};

App.prototype.connect = function connect (pathMatcher, options) {
  this.connectors.push(new Connector(pathMatcher, options));
};

App.prototype.handler = function handler () {
  var app = this;
  return function (request, response) {
    var context = {};
    request.body = "";
    request.on("data", function (chunk) {
      request.body += chunk;
    });
    request.on("end", function () {
      try {
        var connector = app.dispatch(request);
        connector.run(context, request, response);
      } catch (e) {
        // catch and transform HTTP status exceptions.
        // Such should never be thrown in the post-processing pipeline.
        // Consider refactoring to make this restriction de facto, as well as de jure.
        if (e.statusCode) {
          response.setHeader("Content-Length", e.message.length);
          response.writeHead(e.statusCode);
          response.end(e.message);
        } else {
          throw e;
        }
      }
    });
  };
};

App.prototype.requestHandler = function requestHandler () {
  var app = this;
  return function (request, response) {
    var context = {};
    request.body = "";
    request.on("data", function (chunk) { request.body += chunk; });
    request.on("end", function () {
      try {
        var connector = app.dispatch(request);
        if (connector.respond) {
          // Full control of response by the connector
          connector.respond(context, request, response);
        } else {
          // connector processes the request and response,
          // but allows the app to send the response
          connector.process(context, request, response);

          var statusCode = context.statusCode || 200;
          var body = context.responseBody;
          var headers = context.headers || {};
          headers["Content-Length"] = body.length;

          response.writeHeader(statusCode, headers);
          response.end(body);
        }
      } catch (e) {
        if (e.statusCode) {
          response.setHeader("Content-Length", e.message.length);
          response.writeHead(e.statusCode);
          response.end(e.message);
        } else {
          throw e;
        }
      }
      connector.postprocess(context, request, response);
    });
  };
};

App.prototype.dispatch = function dispatch (request) {
  var u = url.parse(request.url);
  var connectors = this.connectors.filter(function (connector) {
    return connector.pathMatcher(u.pathname);
  });

  if (connectors.length === 0) {
    throw new NotFoundException();
  }

  connectors = connectors.filter(function (connector) {
    return connector.methodMatcher(request.method);
  });

  if (connectors.length === 0) {
    throw new NotAllowedException();
  }

  connectors = connectors.filter(function (connector) {
    var mediaType = request.headers["content-type"];
    return connector.contentTypeMatcher(mediaType);
  });

  if (connectors.length === 0) {
    throw new NotSupportedException();
  }
  return connectors[0];

};


//var logBody = function (request) {
  //console.log(JSON.parse(request.body));
//};

//var decodeJSON = function decodeJSON (body) {
  //return JSON.parse(body);
//}

var NotFoundException = function NotFoundException () {
  this.statusCode = 404;
  this.message = "Not Found";
};

var NotAllowedException = function NotFoundException () {
  this.statusCode = 405;
  this.message = "Not Allowed";
};

var NotSupportedException = function NotSupportedException () {
  this.statusCode = 415;
  this.message = "Unsupported Media Type";
};


// Namespaces
exports.processors = require("./quern/processors");
exports.actions = require("./quern/actions");
exports.codecs = require("./quern/codecs");



