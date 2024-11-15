class VideoIndexSearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
      require "open3"

      video = args[0]
      index_path = ActiveStorage::Blob.service.path_for(video.index.key)

      script_path = Rails.root.join("sigclip", "search.py")
      stdout, stderr, status = Open3.capture3("python3", script_path.to_s, "--index", index_path.to_s, "--query", "temple")

      if status.success?
          Rails.logger.info "Successfully processed video search: #{stdout}"
      else
          Rails.logger.error "Error processing video search: #{stderr}"
          raise "Video processing failed: #{stderr}"
      end
  end
end
