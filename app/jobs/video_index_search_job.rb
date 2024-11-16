class VideoIndexSearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
      require "open3"

      video = args[0]
      search_text = args[1]
      index_path = ActiveStorage::Blob.service.path_for(video.index.key)

      script_path = Rails.root.join("sigclip", "search.py")
      # Modify the command to use conda environment
      conda_env = "app_env"  # Replace with your conda environment name
      conda_command = "conda run -n #{conda_env} python3 #{script_path.to_s} --index #{index_path.to_s} --query #{search_text}"
      stdout, stderr, status = Open3.capture3(conda_command)

      if status.success?
          Rails.logger.info "Successfully processed video search: #{stdout}"
          results = JSON.parse(stdout.lines.last)
          Rails.logger.info "Search results: #{results}"
          video.update!(
            metadata: (video.metadata || {}).merge(
                    "search_results" => {
                        "text" => search_text,
                        "results" => results
                    }
                )
            )

      else
          Rails.logger.error "Error processing video search: #{stderr}"
          raise "Video processing failed: #{stderr}"
      end
  end
end
