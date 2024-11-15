class VideoIndexJob < ApplicationJob
    queue_as :default

    def perform(*args)
        require "open3"

        video = args[0]
        video_path = ActiveStorage::Blob.service.path_for(video.file.key)

        script_path = Rails.root.join("sigclip", "index.py")
        stdout, stderr, status = Open3.capture3("python3", script_path.to_s, video_path.to_s)

        if status.success?
            Rails.logger.info "Successfully processed video: #{stdout}"

            temp_dir = Rails.root.join("tmp", video.file.key)
            Rails.logger.info "Processing video frames and index in #{temp_dir}"
            Dir.glob(temp_dir.join("**", "*")).each do |file|
                if file.include?("frame_")
                    Rails.logger.info "Attaching frame #{file}"
                    video.frames.attach(
                        io: File.open(file),
                        filename: file.split("/").last,
                        content_type: "image/png"
                    )
                elsif file.include?("index")
                    Rails.logger.info "Attaching index #{file}"
                    video.index.attach(
                        io: File.open(file),
                        filename: file.split("/").last,
                        content_type: "application/octet-stream"
                    )
                end
            end
        else
            Rails.logger.error "Error processing video: #{stderr}"
            raise "Video processing failed: #{stderr}"
        end
    end
end
