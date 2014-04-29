require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8080

server.mount_proc '/' do |req, res|
  res['Content-Type'] = 'text/text'

  res.body = req.path
end 

trap('INT') { server.stop }

server.start

