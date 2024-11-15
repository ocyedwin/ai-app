class VideoIndexJob < ApplicationJob
    queue_as :default
  
    def perform(*args)
        require 'open3'

        video = args[0]
        video_path = ActiveStorage::Blob.service.path_for(video.file.key)
        
        script_path = Rails.root.join('sigclip', 'index.py')
        stdout, stderr, status = Open3.capture3("python3", script_path.to_s, video_path.to_s)
        
        if status.success?
            Rails.logger.info "Successfully processed video: #{stdout}"
        else
            Rails.logger.error "Error processing video: #{stderr}"
            raise "Video processing failed: #{stderr}"
        end
    end
end
