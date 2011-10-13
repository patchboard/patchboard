
var ResponseWrapper = function ResponseWrapper (serverResponse) {
  this.response = serverResponse;
  this.body = "";
};

ResponseWrapper.prototype = {
  write : function (chunk, encoding) {
    response.write(chunk, encoding);
    // TODO worry about encodings
    this.body += chunk;
  },
  end : function (data, encoding) {
    response.end(data, encoding);
    // TODO worry about encodings
    this.body += data;
  },

};

var RequestWrapper = function RequestWrapper (serverRequest) {
  this.request = serverRequest;
  this.body = "";
  this.data = null;
};
