require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'json'

frame = {
  video_path: "storage/xh/za/xhzaqkh1pcsiw1z7nbhrirtqiean",
  question: "Describe the video in detail."
}.to_json

url = "ws://ai-app_devcontainer_longvu_pg_1:6789"

Async do |task|
  endpoint = Async::HTTP::Endpoint.parse(url)

  Async::WebSocket::Client.connect(endpoint) do |connection|
    puts "Connected to server"
    connection.write(frame)
    puts "Sent message to server"

    # Wait for and process the response
    while message = connection.read
      puts "Received: #{message.to_str}"
      puts "Closing connection..."
      connection.close
      break
    end
  end
  puts "Connection closed"
end
