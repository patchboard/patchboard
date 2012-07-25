// Generated by CoffeeScript 1.3.3
var Classifier, SimpleDispatcher;

Classifier = require("./classifier");

SimpleDispatcher = (function() {
  var Context;

  function SimpleDispatcher(service, handlers) {
    this.service = service;
    this.handlers = handlers;
    this.schema = service.schema;
    this.http_interface = service["interface"];
    this.map = service.map;
    this.install_default_handlers();
    this.supply_missing_handlers();
    this.classifier = new Classifier(this.service);
  }

  SimpleDispatcher.prototype.install_default_handlers = function() {
    var service, service_description, _base, _base1;
    service = this.service;
    service_description = {
      "interface": service["interface"],
      schema: service.schema
    };
    (_base = this.handlers.meta).service_description || (_base.service_description = function(context) {
      var content, headers, match, request, response;
      request = context.request, response = context.response, match = context.match;
      content = JSON.stringify(service_description);
      headers = {
        "Content-Type": "application/json",
        "Content-Length": content.length
      };
      response.writeHead(200, headers);
      return response.end(content);
    });
    return (_base1 = this.handlers.meta).documentation || (_base1.documentation = function(context) {
      var content, headers, match, request, response;
      request = context.request, response = context.response, match = context.match;
      content = service.documentation();
      headers = {
        "Content-Type": "text/plain",
        "Content-Length": content.length
      };
      response.writeHead(200, headers);
      return response.end(content);
    });
  };

  SimpleDispatcher.prototype.supply_missing_handlers = function() {
    var action, definition, dummy_handler, resource, spec, _ref, _results;
    dummy_handler = function(context) {
      var content, headers, match, request, response;
      request = context.request, response = context.response, match = context.match;
      content = JSON.stringify({
        message: "Unimplemented: " + match.resource_type + "." + match.action_name
      });
      headers = {
        "Content-Type": "application/json",
        "Content-Length": content.length
      };
      response.writeHead(501, headers);
      return response.end(content);
    };
    _ref = this.http_interface;
    _results = [];
    for (resource in _ref) {
      definition = _ref[resource];
      _results.push((function() {
        var _base, _base1, _ref1, _results1;
        _ref1 = definition.actions;
        _results1 = [];
        for (action in _ref1) {
          spec = _ref1[action];
          (_base = this.handlers)[resource] || (_base[resource] = {});
          _results1.push((_base1 = this.handlers[resource])[action] || (_base1[action] = dummy_handler));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Context = (function() {

    function Context(request, response, match) {
      this.request = request;
      this.response = response;
      this.match = match;
    }

    return Context;

  })();

  SimpleDispatcher.prototype.create_handler = function() {
    var dispatcher;
    dispatcher = this;
    return function(request, response) {
      return dispatcher.dispatch(request, response);
    };
  };

  SimpleDispatcher.prototype.dispatch = function(request, response) {
    var context, handler, result;
    result = this.classifier.classify(request);
    if (result.error) {
      return this.classification_error(result.error, request, response);
    } else {
      handler = this.find_handler(result);
      context = new Context(request, response, result);
      return handler(context);
    }
  };

  SimpleDispatcher.prototype.classification_error = function(error, request, response) {
    return this.default_error_handler(error, response);
  };

  SimpleDispatcher.prototype.find_handler = function(match) {
    var action, resource;
    if (resource = this.handlers[match.resource_type]) {
      if (action = resource[match.action_name]) {
        return action;
      } else {
        throw "Resource '" + match.resource_type + "' has no such action: " + match.action_name;
      }
    } else {
      throw "No such resource: " + match.resource_type;
    }
  };

  SimpleDispatcher.prototype.default_error_handler = function(error, response) {
    response.writeHead(error.status, {
      "Content-Type": "application/json"
    });
    return response.end(JSON.stringify(error));
  };

  return SimpleDispatcher;

})();

module.exports = SimpleDispatcher;