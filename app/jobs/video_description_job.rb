class VideoDescriptionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    require 'open3'

    video = args[0]
    video_path = ActiveStorage::Blob.service.path_for(video.file.key)
    video_path = video_path.gsub("/home/ubuntu/ai-app/", "")

    command = <<~BASH
      docker exec \
      $(docker ps --format '{{.Names}}' | grep longvu) \
      /opt/conda/bin/conda run -n app_env /bin/bash -c \
      "export CUDA_VISIBLE_DEVICES=0 && \
      export PYTHONPATH=/workspace/app:$PYTHONPATH && \
      cd app && \
      python -u my_ext/inference.py \
      --video_path '#{video_path}' \
      --question 'Describe the video in detail.'"
    BASH

    stdout, stderr, status = Open3.capture3(command)
    
    if status.success?
      Rails.logger.info "Script executed successfully"
      Rails.logger.info "Output: #{stdout}"

      video = Video.first
      video.update!(
        metadata: { description: stdout }
      )

    else
      Rails.logger.error "Script failed with error: #{stderr}"
      raise "Script execution failed with status: #{status.exitstatus}"
    end
  end
end
