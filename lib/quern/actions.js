exports.acceptForProcessing = function (request, response) {
  response.writeHeader(202, {'Content-Length':0});
  response.end();
};
