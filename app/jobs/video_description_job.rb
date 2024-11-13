class VideoDescriptionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    require 'faye/websocket'
    require 'eventmachine'

    video = args[0]
    video_path = ActiveStorage::Blob.service.path_for(video.file.key)
    video_path = video_path.gsub("/home/ubuntu/ai-app/", "")

    # Add timeout handling
    timeout = 60 # 1 minute timeout
    response_received = false

    EM.run {
      timer = EM::Timer.new(timeout) do
        ws&.close
        EM.stop
        raise "WebSocket timeout after #{timeout} seconds"
      end

      ws = Faye::WebSocket::Client.new('ws://127.0.0.1:6789')

      ws.on :open do |event|
        p [:open]
        message_body = {
          video_path: video_path,
          question: "What pokemon are there?"
        }
        ws.send(message_body.to_json)
      end

      ws.on :message do |event|
        p [:message, event.data]
        video.update!(metadata: { description: event.data })
        response_received = true
        timer.cancel
        ws.close
        EM.stop
      end
    
      ws.on :close do |event|
        p [:close, event.code, event.reason]
        EM.stop unless response_received
      end

      ws.on :error do |event|
        p [:error, event.message]
        EM.stop
        raise "WebSocket error: #{event.message}"
      end
    }
  end
end
