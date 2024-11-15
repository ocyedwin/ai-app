class VideosController < ApplicationController
  before_action :set_video, only: %i[ show edit update destroy search]

  # GET /videos or /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1 or /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos or /videos.json
  def create
    puts "video_params: #{video_params}"
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to video_path(@video.uuid), notice: "Video was successfully uploaded." }
        format.json { render :show, status: :created, location: video_path(@video.uuid) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1 or /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: "Video was successfully updated." }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1 or /videos/1.json
  def destroy
    @video.destroy!

    respond_to do |format|
      format.html { redirect_to videos_path, status: :see_other, notice: "Video was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def search
    VideoIndexSearchJob.perform_later(@video, params[:search_text])

    <<~DOC
    current_metadata = @video.metadata || {}
    updated_metadata = current_metadata.merge("search_text" => params[:search_text])
    @video.update(metadata: updated_metadata)

    respond_to do |format|
      format.html { redirect_to video_path(@video.uuid), notice: "Video was successfully updated." }
    end
    DOC
    respond_to do |format|
      format.html { redirect_to video_path(@video.uuid), notice: "Performing search." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      # @video = Video.find(params.expect(:id))
      @video = Video.find_by!(uuid: params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def video_params
      params.expect(video: [ :id, :metadata, :file ])
    end
end
