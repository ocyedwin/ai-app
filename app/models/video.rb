class Video < ApplicationRecord
    before_create :set_uuid
    after_create :generate_description

    has_one_attached :file

    private

    def set_uuid
        self.uuid = "video_#{SecureRandom.uuid}" if id.blank?
    end

    def generate_description
        VideoDescriptionJob.perform_later(self)
    end
end
