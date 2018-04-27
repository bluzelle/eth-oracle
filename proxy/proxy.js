const blz = require('bluzelle');

const http = require('http');
const port = 8080;

const daemonAddress = "13.78.131.94";
const daemonPort = 51010;
//const daemonAddress = "localhost";
//const daemonPort = 8100;

const requestHandler = (request, response) => {
  console.log(request.method, request.url);
  console.log(request.headers);

  var path = request.url.split('/');

  if(path.length != 4){
    response.writeHead(400);
    response.end("bad request");
  }

  // The only information oraclize will give us back is the response body as a
  // string; so there's no use trying to return any other information (like a
  // meaningful http status code)
  var forwardResult = (promise, request) => {
    promise.then(
      value => response.end("ack"),
      error => {
        console.log(error);
        response.end("err");
      }
    );
  };

  // Accumulate the data from a http post and do something with it
  var withData = (request, callback) => {
    content = "";
    request.on('data', data => content += data);
    request.on('end', () => {
      console.log("post data recieved:", content);
      callback(content);
    });
  };

  blz.connect('ws://' + daemonAddress + ':' + daemonPort, path[2]);
  var key = path[3];
  switch(request.method.toString() + path[1].toString()){
    case "GETread":
      blz.read(key).then(
        // We return a constant prefix so that the smart contract can
        // distinguish an error from a string representing an error that's
        // actually stored in the db
        value => response.end("ack" + value.toString()),
        error => {
          console.log(error);
          response.end("err");
        }
      );
      break;

    case "POSTdelete":
      forwardResult(blz.remove(path[3]), request);
      break;

    case "POSTcreate":
      withData(request, data => 
        forwardResult(blz.create(key, data), request));
      break;

    case "POSTupdate":
      withData(request, data =>
        forwardResult(blz.update(key, data), request));
      break;

    default:
      response.writeHead(400);
      response.end("bad request");
  }
}

const server = http.createServer(requestHandler, (err) => {
  return console.log(err);
});

server.listen(port);
