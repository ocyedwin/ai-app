class Video < ApplicationRecord
    broadcasts_refreshes
    before_create :set_uuid
    after_create :generate_description

    has_one_attached :file

    has_one_attached :index
    has_many_attached :frames

    # Add validations
    validates :file, presence: true,
                    content_type: { in: [ "video/mp4" ],
                                  message: "must be a video file (MP4)" },
                    size: { less_than: 50.megabytes,
                           message: "should be less than 50MB" }

    private

    def set_uuid
        self.uuid = "video_#{SecureRandom.uuid}" if id.blank?
    end

    def generate_description
        VideoDescriptionJob.perform_later(self)
        VideoIndexJob.perform_later(self)
    end
end
