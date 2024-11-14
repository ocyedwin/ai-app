require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'json'

# Create an array of test frames
frames = [
  {
    video_path: "storage/xh/za/xhzaqkh1pcsiw1z7nbhrirtqiean",
    question: "Describe the video in detail."
  }.to_json,
  {
    video_path: "storage/m0/wb/m0wb826dhdftfcrq5qqjew9lerzg",
    question: "What happens in this video?"
  }.to_json
]

url = "ws://ai-app_devcontainer_longvu_pg_1:6789"

# Split frames into two groups
group1, group2 = frames.each_slice((frames.length/2.0).ceil).to_a

# Create two threads
[ group1, group2 ].each_with_index do |frame_group, index|
  Thread.new do
    puts "Starting Thread #{index + 1}"

    Async do |task|
      frame_group.map do |frame|
        task.async do
          endpoint = Async::HTTP::Endpoint.parse(url)

          Async::WebSocket::Client.connect(endpoint) do |connection|
            puts "Thread #{index + 1} - Connected to server (#{frame})"
            connection.write(frame)
            puts "Thread #{index + 1} - Sent message to server (#{frame})"

            while message = connection.read
              puts "Thread #{index + 1} - Received for #{frame}: #{message.to_str}"
              puts "Thread #{index + 1} - Closing connection..."
              connection.close
              break
            end
          end
          puts "Thread #{index + 1} - Connection closed for #{frame}"
        end
      end.each(&:wait)
    end
  end
end

# Wait for all threads to complete
Thread.list.each { |t| t.join unless t == Thread.current }
