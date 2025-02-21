class Api::V1::FamilyMembersController < ApplicationController
  before_action :authenticate

  def create
    resource = FamilyMember.new(resource_params)

    resource.family = Family.where(account_id: current_account.id).first

    if resource.save
      render json: resource, status: :created
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    resource = FamilyMember.find(params[:id])
    file = params.dig(:data, :attributes, :profile_picture)
    if file.present?
      resource.profile_picture.attach(file)
      if resource.profile_picture.attached?
        render json: { profile_picture_url: rails_blob_url(resource.profile_picture, only_path: true) }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["No profile picture provided"] }, status: :unprocessable_entity
    end
  end

  def delete_profile_picture
    resource = FamilyMember.find(params[:id])
    if resource.profile_picture.attached?
      resource.profile_picture.purge
      head :no_content
    else
      render json: { errors: ["No profile picture attached"] }, status: :unprocessable_entity
    end
  end

  def update_signature
    resource = FamilyMember.find(params[:id])
    file = params.dig(:data, :attributes, :signature)
    if file.present?
      resource.signature.attach(file)
      if resource.signature.attached?
        render json: { signature_url: rails_blob_url(resource.signature, only_path: true) }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["No signature provided"] }, status: :unprocessable_entity
    end
  end

  def delete_signature
    resource = FamilyMember.find(params[:id])
    if resource.signature.attached?
      resource.signature.purge
      head :no_content
    else
      render json: { errors: ["No signature attached"] }, status: :unprocessable_entity
    end
  end

  def upload_images
    resource = FamilyMember.find(params[:id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    files = params.dig(:data, :attributes, :images)
    unless files.present?
      return render json: { errors: ["Nebyl poskytnut žádný soubor"] }, status: :unprocessable_entity
    end

    # Předpokládáme, že files je pole souborů
    files.each do |file|
      unless file.content_type.start_with?('image/')
        return render json: { errors: ["Povolené jsou pouze obrázky"] }, status: :unprocessable_entity
      end
      resource.images.attach(file)
    end

    images = resource.images.map do |img|
      { id: img.id, url: rails_blob_url(img, only_path: true) }
    end

    render json: { images: images }, status: :ok
  end

  def delete_image
    resource = FamilyMember.find(params[:family_member_id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    image = resource.images.find_by(id: params[:image_id])
    if image
      image.purge
      head :no_content
    else
      render json: { errors: ["Obrázek nenalezen"] }, status: :not_found
    end
  end

  def show_images
    resource = FamilyMember.find(params[:id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    images = resource.images.map do |img|
      { id: img.id, url: rails_blob_url(img, only_path: true) }
    end

    render json: { images: images }, status: :ok
  end

  protected

  def create_resource(object, context)
    family = Family.where(account_id: current_account.id).first

    if family && object.respond_to?(:family=)
      object.family = family
    end

    super
  end

  private

  def resource_params
    params.require(:data).require(:attributes).permit(:first_name, :last_name, :date_of_birth, :date_of_death)
  end
end
