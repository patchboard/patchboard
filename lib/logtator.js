var fs = require("fs");

var Logtator = function Logtator (options) {
  options = options || {};
  this.cache = {};
  this.idleTimeout = options.idleTimeout || 180 * 60 * 1000; // ms.
  this.collectionInterval = options.collectionInterval || 60 * 60 * 1000; // ms.
  setInterval(this.collectStreams(), this.collectionInterval);
};

Logtator.prototype.collectStreams = function collectStreams () {
  var tator = this;
  return function () {
    console.log("Checking for idle logs");
    var c = tator.cache;
    var cutoff = new Date() - tator.idleTimeout;
    for (var path in c) {
      if (c.hasOwnProperty(path)) {
        var stream = c[path];
        if (stream.lastAccess < cutoff) {
          stream.destroySoon();
          delete c[path];
          console.log("Collected " + path);
        }
      }
    }
  };
};

Logtator.prototype.getStream = function getStream (path) {
  var stream = this.cache[path];
  if (stream) {
    return stream;
  } else {
    var stream = fs.createWriteStream(path, {flags: "a"});
    stream.lastAccess = new Date();
    stream.on("drain", function () {
      console.log("drained " + this.path);
      stream.lastAccess = new Date();
    });
    this.cache[path] = stream;
    return stream;
  }
};

var DemuxLogger = function DemuxLogger (basePath, options) {
  this.logtator = new Logtator(options);
  this.basePath = basePath;
};

DemuxLogger.prototype.log = function log (desc, object) {
  if (typeof(desc) === "string") {
    desc = [desc];
  }
  var path = this.path(desc);
  var stream = this.logtator.getStream(path);
  stream.write(object + "\n");
};

DemuxLogger.prototype.path = function path (descArray) {
  return this.basePath + "." + descArray.join(".") + ".log";
};

// Log path will be based on the timestamp of the event.  Effectively
// achieves the same effect as log rotation based on dates.  Perhaps
// of doubtful usefulness.
var DateDemuxLogger = function DateDemuxLogger (basePath, options) {
  DemuxLogger.call(this, basePath, options);
};

DateDemuxLogger.prototype = new DemuxLogger();

DateDemuxLogger.prototype.log = function log (desc, object, timestampInSeconds) {
  if (typeof(desc) === "string") {
    desc = [desc];
  }
  desc.unshift(this.format(timestampInSeconds));
  var path = this.path(desc);
  var stream = this.logtator.getStream(path);
  stream.write(object + "\n");
};

// return date as YYYY-MM-DD string
DateDemuxLogger.prototype.format = function format (timestampInSeconds) {
  var date = timestampInSeconds ? new Date(timestampInSeconds * 1000) : new Date();
  return date.toISOString().slice(0,10);
};


exports.Logtator = Logtator;
exports.DemuxLogger = DemuxLogger;
exports.DateDemuxLogger = DateDemuxLogger;

//var logger = new DateDemuxLogger(
  //"/tmp/logs/tator",
  //{
    //idleTimeout: 6 * 1000,
    //collectionInterval: 3 * 1000
  //}
//);
//logger.log("request", "http://monkey.com/shines : 200 :");
//logger.log(["dis", "error"], "something went SERIOUSLY wrong");


//setTimeout(function () {
  //logger.log("request", "after stream close\n\n");
//}, 8 * 1000);

