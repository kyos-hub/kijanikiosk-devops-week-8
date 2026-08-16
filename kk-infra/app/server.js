// server.js — kk-payments minimal app (plain JS, no build step)
// Reads APP_VERSION and PORT from environment so the same code
// serves as both the "blue" and "green" instance.
const http = require('http');

const VERSION = process.env.APP_VERSION || 'unknown';
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', version: VERSION, pid: process.pid }));
    return;
  }
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ service: 'kk-payments', version: VERSION }));
});

server.listen(PORT, () => {
  console.log(`kk-payments ${VERSION} listening on ${PORT}`);
});
