// proxy_server.js  –  run with: node proxy_server.js
const http = require('http');
const https = require('https');

const PORT = 8080;
const ANTHROPIC_HOST = 'api.anthropic.com';

const server = http.createServer((req, res) => {
  // ── CORS headers (allow Flutter web on any localhost port) ──
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, x-api-key, anthropic-version');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method !== 'POST' || req.url !== '/v1/messages') {
    res.writeHead(404);
    res.end('Not found');
    return;
  }

  let body = '';
  req.on('data', chunk => body += chunk.toString());
  req.on('end', () => {
    const options = {
      hostname: ANTHROPIC_HOST,
      path: '/v1/messages',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': req.headers['x-api-key'] || '',
        'anthropic-version': req.headers['anthropic-version'] || '2023-06-01',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    const proxyReq = https.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      });
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
      console.error('Proxy error:', err);
      res.writeHead(502);
      res.end(JSON.stringify({ error: err.message }));
    });

    proxyReq.write(body);
    proxyReq.end();
  });
});

server.listen(PORT, () => {
  console.log(`✅ Anthropic proxy running at http://localhost:${PORT}`);
  console.log(`   Point Flutter web to: http://localhost:${PORT}/v1/messages`);
});
