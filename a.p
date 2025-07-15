from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"Hello, world!")

if __name__ == "__main__":
    server_address = ('', 8000)  # '' = all interfaces, port 8000
    httpd = HTTPServer(server_address, SimpleHandler)
    print("Server running on http://localhost:8000")
    httpd.serve_forever()