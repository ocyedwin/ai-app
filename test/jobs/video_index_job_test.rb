require 'test_helper'

class VideoIndexJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper
  
  setup do
    @video = Video.find(videos(:one).id) # Assuming you have a video fixture
    
    # Set up the test video file
    file_path = Rails.root.join('test', 'fixtures', 'files', 'test.mp4')
    raise "Test video file not found at #{file_path}" unless File.exist?(file_path)

    @video.file.attach(
      io: File.open(file_path),
      filename: 'test.mp4',
      content_type: 'video/mp4'
    )
  end

  test "processes video successfully" do
    assert_performed_jobs 1, only: VideoIndexJob do
      VideoIndexJob.perform_later(@video)
    end
  end
end
