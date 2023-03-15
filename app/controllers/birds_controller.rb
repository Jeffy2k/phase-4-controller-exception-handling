class BirdsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

  # GET /birds
  def index
    birds = Bird.all
    render json: birds
  end

  # POST /birds
  def create
    bird = Bird.create!(bird_params)
    render json: bird, status: :created
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { errors: invalid.record.errors }, status: :unprocessable_entity
  end

  # GET /birds/:id
  def show
    bird = find_bird
    render json: bird
  rescue ActiveRecord::RecordNotFound
    render_not_found_response
  end
  
  # PATCH /birds/:id
  def update
    bird = find_bird
    # update! exceptions will be handled by the rescue_from ActiveRecord::RecordInvalid code
    bird.update!(bird_params)
    render json: bird
  end

  # PATCH /birds/:id/like
  def increment_likes
    bird = Bird.find_by(id: params[:id])
    if bird
      bird.update(likes: bird.likes + 1)
      render json: bird
    else
      render_not_found_response
    end
  end

  # DELETE /birds/:id
  def destroy
    bird = Bird.find_by(id: params[:id])
    if bird
      bird.destroy
      head :no_content
    else
      render_not_found_response
    end
  end

  private

  def bird_params
    params.permit(:name, :species, :likes)
  end

  def find_bird
    Bird.find_by(id: params[:id])
  end

  def render_not_found_response
    render json: { error: "Bird not found" }, status: :not_found
  end

  def render_unprocessable_entity_response(invalid)
    render json: { errors: invalid.record.errors }, status: :unprocessable_entity
  end


end
