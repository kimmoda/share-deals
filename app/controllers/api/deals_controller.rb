class Api::DealsController < ApplicationController
  def index
    @deals = Deal
      .joins('LEFT JOIN thumbs ON deals.id = thumbs.deal_id')
      .group('deals.id')
      .having('count (thumbs.id) > 8')
      .order('count (thumbs.id) DESC')

    deal_ids = @deals.pluck(:id)

    @thumb_sums =
      Thumb
        .select(:deal_id)
        .where(deal_id: deal_ids)
        .group(:deal_id)
        .sum(:value)

    if logged_in?
      @thumb_values =
        current_user.thumbs
          .select(:deal_id)
          .where(deal_id: deal_ids)
          .group(:deal_id)
          .sum(:value)

      @thumb_ids =
        current_user.thumbs
          .select(:deal_id)
          .where(deal_id: deal_ids)
          .group(:deal_id)
          .sum(:id)
    else
      @thumb_values = {}
      @thumb_ids = {}
    end
  end

  def show
    @deal = Deal.find(params[:id])

    if logged_in?
      @thumb = current_user.thumbs.where(deal_id: @deal.id).as_json.first
    else
      @thumb = {}
    end
  end

  def create
    @deal = Deal.new(deal_params)

    if @deal.valid?
      begin
        unless deal_params[:image_url].empty?
          response = Cloudinary::Uploader.upload(@deal.image_url)
          @deal.cloud_url = response['secure_url']
          @deal.cloud_public_id = response['public_id']
        end
        @deal.save
        render :show
      rescue
        render json: ["Invalid Image URL"], status: 422
      end
    else
      render json: @deal.errors.full_messages, status: 422
    end
  end

  def update
    @deal = current_user.deals.find(params[:id])

    if @deal
      old_image_url = @deal.image_url
      @deal.assign_attributes(deal_params)
      if @deal.valid?
        begin
          if @deal.cloud_public_id && deal_params[:image_url].empty?
            Cloudinary::Uploader.destroy(@deal.cloud_public_id, invalidate: true)

            @deal.cloud_url = nil
            @deal.cloud_public_id = nil
          elsif (old_image_url != deal_params[:image_url]) && !deal_params[:image_url].empty?
            response = Cloudinary::Uploader.upload(@deal.image_url)
            if @deal.cloud_public_id
              Cloudinary::Uploader.destroy(@deal.cloud_public_id, invalidate: true)
            end

            @deal.cloud_url = response['secure_url']
            @deal.cloud_public_id = response['public_id']
          end

          @deal.save
          render :show
        rescue
          render json: ["Invalid Image URL"], status: 422
        end
      else
        render json: @deal.errors.full_messages, status: 422
      end
    else
      render json: {}, status: 422
    end
  end

  def destroy
    @deal = current_user.deals.find(params[:id])

    if @deal
      if @deal.cloud_public_id
        Cloudinary::Uploader.destroy(@deal.cloud_public_id, invalidate: true)
      end
      @deal.destroy
      render :show
    else
      render json: {}, status: 422
    end
  end

  private

  def deal_params
    params.require(:deal).permit(
      :category, :title, :price, :vendor, :description, :deal_url,
      :image_url, :author_id
    )
  end
end
