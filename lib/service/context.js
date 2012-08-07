// Generated by CoffeeScript 1.3.3
var Context;

Context = (function() {

  function Context(request, response, match) {
    this.request = request;
    this.response = response;
    this.match = match;
  }

  Context.prototype.set_cors_headers = function(origin) {
    if (this.request.headers["origin"]) {
      origin || (origin = this.request.headers["origin"]);
      return this.response.setHeader("Access-Control-Allow-Origin", origin);
    }
  };

  Context.prototype.respond = function(status, content, headers) {
    if (status === 202 || status === 204 || !content) {
      content = "";
    }
    headers || (headers = {});
    if (content.constructor !== String) {
      content = JSON.stringify(content);
    }
    headers["Content-Length"] = content.length;
    if (this.match.accept) {
      headers["Content-Type"] || (headers["Content-Type"] = this.match.accept);
    }
    this.response.writeHead(status, headers);
    return this.response.end(content);
  };

  return Context;

})();

module.exports = Context;