#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 8000;

const server = http.createServer((req, res) => {
  // Parse the request URL
  const parsedUrl = url.parse(req.url);
  const pathname = parsedUrl.pathname;
  
  // Get the file path
  let filePath = '.' + pathname;
  if (filePath === './') {
    filePath = './index.html';
  }
  
  // Get file extension
  const extname = path.extname(filePath);
  
  // Debug request
  console.log(`Request: ${req.method} ${req.url}`);
  console.log(`Range header: ${req.headers.range}`);
  
  // Set content type based on file extension
  let contentType = 'text/html';
  switch (extname) {
    case '.js':
      contentType = 'text/javascript';
      break;
    case '.css':
      contentType = 'text/css';
      break;
    case '.json':
      contentType = 'application/json';
      break;
    case '.png':
      contentType = 'image/png';
      break;
    case '.jpg':
      contentType = 'image/jpg';
      break;
    case '.mp4':
      contentType = 'video/mp4';
      break;
    case '.m3u8':
      contentType = 'application/vnd.apple.mpegurl';
      break;
    case '.ts':
      contentType = 'video/mp2t';
      break;
  }
  
  // Check if the file exists
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      console.log(`File not found: ${filePath}`);
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File not found');
      return;
    }
    
    // File exists, get its stats
    fs.stat(filePath, (err, stats) => {
      if (err) {
        console.log(`Error getting file stats: ${err}`);
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Internal Server Error');
        return;
      }
      
      const fileSize = stats.size;
      
      // Handle Range header for byte range requests
      const rangeHeader = req.headers.range;
      
      if (rangeHeader) {
        // Parse Range header value
        const rangeMatch = rangeHeader.match(/bytes=(\d+)-(\d*)/);
        
        if (!rangeMatch) {
          console.log(`Invalid Range header: ${rangeHeader}`);
          res.writeHead(416, { 
            'Content-Type': 'text/plain',
            'Content-Range': `bytes */${fileSize}`
          });
          res.end('Range Not Satisfiable');
          return;
        }
        
        const start = parseInt(rangeMatch[1], 10);
        const end = rangeMatch[2] ? parseInt(rangeMatch[2], 10) : fileSize - 1;
        
        // Validate range
        if (start >= fileSize || start < 0 || end >= fileSize || start > end) {
          console.log(`Invalid range values: start=${start}, end=${end}, fileSize=${fileSize}`);
          res.writeHead(416, { 
            'Content-Type': 'text/plain',
            'Content-Range': `bytes */${fileSize}`
          });
          res.end('Range Not Satisfiable');
          return;
        }
        
        const chunkSize = (end - start) + 1;
        
        console.log(`Serving bytes ${start}-${end}/${fileSize} (${chunkSize} bytes)`);
        
        // Set response headers for partial content
        res.writeHead(206, {
          'Content-Range': `bytes ${start}-${end}/${fileSize}`,
          'Accept-Ranges': 'bytes',
          'Content-Length': chunkSize,
          'Content-Type': contentType
        });
        
        // Create read stream with specified byte range
        const fileStream = fs.createReadStream(filePath, { start, end });
        
        fileStream.on('error', (err) => {
          console.log(`Error reading file: ${err}`);
          res.end();
        });
        
        // Pipe the file stream to the response
        fileStream.pipe(res);
      } else {
        // Handle normal request (no Range header)
        console.log(`Serving full file (${fileSize} bytes)`);
        
        res.writeHead(200, {
          'Content-Length': fileSize,
          'Content-Type': contentType,
          'Accept-Ranges': 'bytes' // Important to indicate range requests are supported
        });
        
        const fileStream = fs.createReadStream(filePath);
        
        fileStream.on('error', (err) => {
          console.log(`Error reading file: ${err}`);
          res.end();
        });
        
        fileStream.pipe(res);
      }
    });
  });
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});
