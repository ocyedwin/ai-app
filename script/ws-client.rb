require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'thread'

def process_videos(videos)
  EM.run {
    connections = videos.map do |video|
      ws = Faye::WebSocket::Client.new('ws://ai-app_devcontainer_longvu_pg_1:6789')

      ws.on :open do |event|
        p [ "Connection #{ws.object_id}", :open, 'Connection established' ]
        message_body = {
          video_path: video[:path],
          question: video[:question]
        }
        ws.send(message_body.to_json)
      end

      ws.on :message do |event|
        p [ "Connection #{ws.object_id}", :message, event.data ]
        # Count completed connections
        @completed_count ||= 0
        @completed_count += 1
        # Stop EM when all connections are done
        EM.stop if @completed_count == videos.length
      end

      ws.on :close do |event|
        p [ "Connection #{ws.object_id}", :close, event.code, event.reason ]
        ws = nil
      end

      ws.on :error do |event|
        p [ "Connection #{ws.object_id}", :error, event.message ]
      end

      ws
    end
  }
end

# Example usage
videos = [
  {
    path: "storage/xh/za/xhzaqkh1pcsiw1z7nbhrirtqiean",
    question: "Describe the video in detail."
  },
  {
    path: "storage/m0/wb/m0wb826dhdftfcrq5qqjew9lerzg",
    question: "What happens in this video?"
  }
  # Add more video/question pairs as needed
]

process_videos(videos)
