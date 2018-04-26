const blz = require('bluzelle');

const http = require('http');
const port = 8080;

const requestHandler = (request, response) => {
  console.log(request.url);
  path = request.url.split('/');

  if(path.length == 4  && path[1] === 'get'){

    blz.connect('ws://127.0.0.1:8100', path[2])

    console.log('reading');
    blz.read(path[3]).then(
      value => {
        response.end(JSON.stringify(value));
      },
      error => {
        response.writeHead(404);
        response.end("no such key");
      }
    );
    console.log('read returned');

  }else{
    response.writeHead(400);
    response.end("bad request");
  }
}

const server = http.createServer(requestHandler, (err) => {
  return console.log(err);
});

server.listen(port);
