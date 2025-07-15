from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"<h1>Hello from Python HTTP server!</h1>")

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        print("Received POST data:", body.decode())
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"POST received")

server_address = ("", 3000)
httpd = HTTPServer(server_address, SimpleHandler)
print("Serving on http://localhost:3000")
httpd.serve_forever()
