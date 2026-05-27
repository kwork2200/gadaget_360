// mobileapi_proxy.js - Backend proxy for MobileAPI (100% CORS-free solution)
// Run with: node mobileapi_proxy.js

const express = require('express');
const fetch = require('node-fetch');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());

// CORS headers for Flutter Web
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'MobileAPI Proxy is running' });
});

// Search endpoint - Flutter calls this, proxy calls MobileAPI
app.get('/search', async (req, res) => {
  try {
    const { name } = req.query;
    
    if (!name) {
      return res.status(400).json({ error: 'Search name is required' });
    }

    console.log(`🔍 Searching for: ${name}`);

    // Call the real MobileAPI
    const response = await fetch(
      `https://api.mobileapi.dev/devices/search?name=${encodeURIComponent(name)}`,
      {
        method: 'GET',
        headers: {
          'Authorization': 'Token e69c7e072fc8d593751bbd54ec09d552815bed4a',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
      }
    );

    const data = await response.json();
    
    console.log(`✅ Found ${data.devices?.length || 0} results`);
    
    // Send back to Flutter with proper CORS headers
    res.json(data);
    
  } catch (error) {
    console.error('❌ Proxy error:', error);
    res.status(500).json({ 
      error: 'Proxy server error',
      message: error.message 
    });
  }
});

// Product details endpoint
app.get('/product/:productName', async (req, res) => {
  try {
    const { productName } = req.params;
    
    console.log(`📱 Fetching product: ${productName}`);

    // Call the real MobileAPI search to find the product
    const response = await fetch(
      `https://api.mobileapi.dev/devices/search?name=${encodeURIComponent(productName)}`,
      {
        method: 'GET',
        headers: {
          'Authorization': 'Token e69c7e072fc8d593751bbd54ec09d552815bed4a',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
      }
    );

    const data = await response.json();
    
    // Return first product found
    if (data.devices && data.devices.length > 0) {
      console.log(`✅ Found product: ${data.devices[0].name}`);
      res.json(data.devices[0]);
    } else {
      res.status(404).json({ error: 'Product not found' });
    }
    
  } catch (error) {
    console.error('❌ Product proxy error:', error);
    res.status(500).json({ 
      error: 'Proxy server error',
      message: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 MobileAPI Proxy Server running at http://localhost:${PORT}`);
  console.log(`📱 Flutter Web should call: http://localhost:${PORT}/search?name=oppo`);
  console.log(`💡 No more CORS issues!`);
  console.log(`🔧 Health check: http://localhost:${PORT}/health`);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down proxy server...');
  process.exit(0);
});
