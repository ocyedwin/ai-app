class VideoDescriptionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    require "async"
    require "async/http/endpoint"
    require "async/websocket/client"

    video = args[0]
    video_path = ActiveStorage::Blob.service.path_for(video.file.key)
    video_path = "storage#{video_path.split("storage").last}"

    url = Rails.env.development? ? "ws://ai-app_devcontainer_longvu_pg_1:6789" : "ws://ai_app-longvu_pg:6789"

    Async do |task|
      task.async do
        endpoint = Async::HTTP::Endpoint.parse(url)

        frame = {
          video_path: video_path,
          question: "Describe the video in detail."
        }.to_json

        Async::WebSocket::Client.connect(endpoint) do |connection|
          puts "Connected to server (#{frame})"
          connection.write(frame)
          puts "Sent message to server (#{frame})"

          while message = connection.read
            puts "Received for #{frame}: #{message.to_str}"
            video.update!(metadata: { description: message.to_str })
            puts "Closing connection..."
            connection.close
            break
          end
        end
      end
    end
  end
end
