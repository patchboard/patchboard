
var Connector = module.exports = function (pathMatcher, options) {
  if (pathMatcher === undefined) { throw "must specify pathMatcher" }
  if (options.method === undefined) { throw "must specify method" }
  if (options.respond === undefined) { throw "must specify a respond function" }

  this.setPathMatcher(pathMatcher);
  this.setMethodMatcher(options.method);
  this.setContentTypeMatcher(options.contentTypes);
  this.contentTypes = options.contentTypes || {};

  this.respond = options.respond;
  this.after = options.after || [];
};

Connector.prototype.run = function run (context, request, response) {
  // decode the entity body
  var mediaType = request.headers['content-type'];
  var decoder = this.contentTypes[mediaType];
  if (decoder) {
    request.data = decoder(request.body);
  }
  // respond and close the request.
  this.respond(request, response);
  this.postprocess(context, request, response);
};

Connector.prototype.process = function process (context, request, response) {
};

// run the post-response pipeline
Connector.prototype.postprocess = function postprocess (context, request, response) {
  this.after.forEach(function (fn) {
    fn(context, request, response);
  });
};

Connector.prototype.setPathMatcher = function setPathMatcher (pm) {
  var c = pm.constructor;
  if (c === String) {
    this.pathMatcher = function (path) {
      return (path === pm);
    };
  } else if (c === RegExp) {
    this.pathMatcher = function (path) {
      return pm.test(path);
    }
  } else if (typeof(pm) === "function") {
    this.pathMatcher = pm;
  }
};

Connector.prototype.setMethodMatcher = function setMethodMatcher (obj) {
  this.methodMatcher = function (method) {
    return obj === method;
  };
};

Connector.prototype.setContentTypeMatcher = function setContentTypeMatcher (obj) {
  if (obj) {
    this.contentTypeMatcher = function (mediaType) {
      return obj.hasOwnProperty(mediaType);
    };
  } else {
    this.contentTypeMatcher = function (mediaType) {
      return true;
    }
  }
};


