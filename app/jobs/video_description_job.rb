class VideoDescriptionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    require "faye/websocket"
    require "eventmachine"

    video = args[0]
    video_path = ActiveStorage::Blob.service.path_for(video.file.key)
    video_path = "storage/#{video_path.split("storage").last}"

    # Add timeout handling
    timeout = 60 # 1 minute timeout
    response_received = false

    EM.run {
      timer = EM::Timer.new(timeout) do
        ws&.close
        EM.stop
        raise "WebSocket timeout after #{timeout} seconds"
      end

      ws = Faye::WebSocket::Client.new("ws://ai_app-longvu_pg:6789")

      ws.on :open do |event|
        p [:open]
        message_body = {
          video_path: video_path,
          question: "Describe the video in detail."
        }.compact
        
        begin
          ws.send(message_body.to_json)
        rescue => e
          Rails.logger.error("Failed to send WebSocket message: #{e.message}")
          ws.close
          EM.stop
          raise
        end
      end

      ws.on :message do |event|
        p [ :message, event.data ]
        video.update!(metadata: { description: event.data })
        response_received = true
        timer.cancel
        ws.close
        EM.stop
      end

      ws.on :close do |event|
        p [ :close, event.code, event.reason ]
        EM.stop unless response_received
      end

      ws.on :error do |event|
        p [ :error, event.message ]
        EM.stop
        raise "WebSocket error: #{event.message}"
      end
    }
  end
end
