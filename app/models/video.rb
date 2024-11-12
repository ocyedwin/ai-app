class Video < ApplicationRecord
    before_create :set_uuid

    has_one_attached :file

    private

    def set_uuid
        self.uuid = "video_#{SecureRandom.uuid}" if id.blank?
    end
end
