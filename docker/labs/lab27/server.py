from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        message = b"Hello from Compose backend"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(message)))
        self.end_headers()
        self.wfile.write(message)

server = HTTPServer(("0.0.0.0", 8080), Handler)
print("Backend listening on port 8080", flush=True)
server.serve_forever()
