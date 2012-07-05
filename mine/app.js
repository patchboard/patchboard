var quern = require("./lib/quern");
var discern = require("./lib/discern");
var logtator = require("./lib/logtator");

var codecs = quern.codecs;

var app = new quern.App();

var logger = new logtator.DemuxLogger("/tmp/logs/tator");

app.connect("/events", {
  method : "POST",
  contentTypes : {
    "application/json" : codecs.json.decode,
    "application/x-www-form-urlencoded" : codecs.form.decode
  },
  respond : quern.actions.acceptForProcessing,
  after : [
    quern.processors.debugBody,
    discern.processors.logEvent(logger)
  ]
});

app.connect("/bogus", {
  method : "GET",
  respond : function (request, response) {
    var body = "Bogus\n";
    response.writeHeader(200, {'Content-Length':body.length});
    response.end(body);
  },
  after : [
    quern.processors.debugBody,
  ]
});

// // Future version of the interface?
//app.connect("/bogus", {
  //"accept" : {
    //"application/json" : codecs.json.encode,
    //"application/yaml" : codecs.yaml.encode
  //},
  //"contentTypes" : {
    //"application/json" : codecs.json.decode,
    //"application/x-www-form-urlencoded" : codecs.form.decode
  //},
  //"methods" : {
    //"POST" : {
      //before : [],
      //respond : function () {},
      //after : []
    //}
  //}
//});

app.run();


