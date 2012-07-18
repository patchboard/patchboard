var account_secret = 'Ac-wfMp5MKCQUCFVZlh6cto5Qbg-AQ'
var spire_url = 'http://localhost:1337'

$(document).ready(function() {
  var Spire = require('./spire.io.js');
  var spire = new Spire({url: spire_url});
  spire.start(account_secret, function (error) {
    if (!error) {
      spire.subscribe(["test"],function(messages) {
        $(messages).each(function(i, message) {
          $('body').append("<p>" + message.content + "</p>");
        });
      });
      spire.publish("test", "Greetings Earthling!");
    }
  });
});


