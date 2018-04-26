const blz = require('bluzelle');

const http = require('http');
const port = 8080;

const requestHandler = (request, response) => {
  console.log(request.url);
  path = request.url.split('/');
  if(path.length == 4  && path[1] === 'get'){
    response.end("fetch!!");
    // Fetch from bluzelle here
  }else{
    response.writeHead(400);
    response.end("bad request");
  }
}

const server = http.createServer(requestHandler, (err) => {
  return console.log(err);
});

server.listen(port);
