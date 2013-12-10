require('coffee-script');

var app = require('./server');

app().then(
  function(server) {
    console.log('Express server started on ' + server.address().port);
  }
).catch(
  function(err) {
    console.error(err);
  }
);
