exports.processors = {}

exports.processors.logEvent = function logEvent (logger) {
  return function (app, request) {
    var data = request.data.forEach ? request.data : [request.data];
    data.forEach(function (ev) {
      // TODO consider the sanity of this log API
      var desc = [];
      if (ev.service) { desc.push(ev.service) }
      if (ev["event"]) { desc.push(ev["event"]) }
      logger.log(desc, JSON.stringify(ev), ev.timestamp);
    });
  };
};
