class Video < ApplicationRecord
    before_create :set_uuid

    private

    def set_uuid
        self.uuid = "video_#{SecureRandom.uuid}" if id.blank?
    end
end
