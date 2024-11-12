class HomeController < ApplicationController
  def index
    @videos = Video.all
  end

  def create
    @video = Video.new(file: params[:video])
    
    if @video.save
      redirect_to root_path, notice: 'Video uploaded successfully!'
    else
      redirect_to root_path, alert: 'Error uploading video.'
    end
  end
end
  