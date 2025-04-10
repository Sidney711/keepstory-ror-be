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

  def update
    resource = FamilyMember.find(params[:id])

    unless resource.family.account_id == current_account.id
      render json: { errors: ["Forbidden"] }, status: :forbidden and return
    end

    if params[:data][:relationships]
      if params[:data][:relationships][:mother] && params[:data][:relationships][:mother][:data]
        resource.mother_id = params[:data][:relationships][:mother][:data][:id]
      end
      if params[:data][:relationships][:father] && params[:data][:relationships][:father][:data]
        resource.father_id = params[:data][:relationships][:father][:data][:id]
      end
    end

    if resource.update(update_params)
      render json: resource, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    resource = FamilyMember.find(params[:id])
    file = params.dig(:data, :attributes, :profile_picture)

    if file.present?
      if file.size > 300.megabytes
        render json: { errors: ["Profile picture must be less than 300 MB"] }, status: :unprocessable_entity and return
      end

      allowed_types = ["image/jpeg", "image/png", "image/gif"]
      unless allowed_types.include?(file.content_type)
        render json: { errors: ["Only image files (JPEG, PNG, GIF) are allowed"] }, status: :unprocessable_entity and return
      end

      original_data = file.read
      compressed_data = compress_image(original_data, max_width: 500, quality: 50)
      compressed_io = StringIO.new(compressed_data)

      resource.profile_picture.attach(
        io: compressed_io,
        filename: file.original_filename,
        content_type: file.content_type
      )

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
      if file.size > 300.megabytes
        render json: { errors: ["Signature must be less than 300 MB"] }, status: :unprocessable_entity and return
      end

      allowed_types = ["image/jpeg", "image/png", "image/gif"]
      unless allowed_types.include?(file.content_type)
        render json: { errors: ["Only image files (JPEG, PNG, GIF) are allowed for signature"] }, status: :unprocessable_entity and return
      end

      original_sig = file.read
      compressed_sig = compress_image(original_sig, max_width: 500, quality: 50)
      sig_io = StringIO.new(compressed_sig)

      resource.signature.attach(
        io: sig_io,
        filename: file.original_filename,
        content_type: file.content_type
      )

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

    files.each do |file|
      unless file.content_type.start_with?('image/')
        return render json: { errors: ["Povolené jsou pouze obrázky"] }, status: :unprocessable_entity
      end
      if file.size > 300.megabytes
        return render json: { errors: ["Každý obrázek musí být menší než 300 MB"] }, status: :unprocessable_entity
      end
    end

    ActiveRecord::Base.transaction do
      files.each do |file|
        original_img = file.read
        compressed_img = compress_image(original_img, max_width: 500, quality: 50)
        io_obj = StringIO.new(compressed_img)
        resource.images.attach(
          io: io_obj,
          filename: file.original_filename,
          content_type: file.content_type
        )
      end
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
      {
        id: img.id,
        url: img.blob.service.url(
          img.blob.key,
          expires_in: 1.hour.to_i,
          filename: img.blob.filename,
          disposition: 'inline',
          content_type: img.blob.content_type
        )
      }
    end

    render json: { images: images }, status: :ok
  end

  def upload_documents
    resource = FamilyMember.find(params[:id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    files = params.dig(:data, :attributes, :documents)
    unless files.present?
      return render json: { errors: ["Nebyl poskytnut žádný soubor"] }, status: :unprocessable_entity
    end

    files.each do |file|
      if file.size > 10.gigabytes
        return render json: { errors: ["Každý dokument musí být menší než 10 GB"] }, status: :unprocessable_entity
      end
    end

    ActiveRecord::Base.transaction do
      files.each do |file|
        resource.documents.attach(file)
      end
    end

    documents = resource.documents.map do |document|
      {
        id: document.id,
        url: rails_blob_url(document, only_path: true),
        filename: document.filename.to_s,
        created_at: document.created_at
      }
    end

    render json: { documents: documents }, status: :ok
  end

  def delete_document
    resource = FamilyMember.find(params[:family_member_id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    document = resource.documents.find_by(id: params[:document_id])
    if document
      document.purge
      return head :no_content
    end

    export_doc = resource.exports.find_by(id: params[:document_id])
    if export_doc
      export_doc.purge
      return head :no_content
    end

    family_export = resource.family.exports.find_by(id: params[:document_id])
    if family_export
      family_export.purge
      return head :no_content
    end

    render json: { errors: ["Dokument nenalezen"] }, status: :not_found
  end

  def show_documents
    resource = FamilyMember.find(params[:id])
    unless resource.family.account_id == current_account.id
      return render json: { errors: ["Neoprávněný přístup"] }, status: :forbidden
    end

    render json: { documents: all_documents_for(resource) }, status: :ok
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

  def all_documents_for(resource)
    documents = resource.documents.map do |document|
      {
        id: document.id,
        url: document.blob.service.url(
          document.blob.key,
          expires_in: 1.hour.to_i,
          filename: document.blob.filename,
          disposition: 'attachment',
          content_type: document.blob.content_type
        ),
        filename: document.filename.to_s,
        created_at: document.created_at,
        type: "uploaded"
      }
    end

    if resource.exports.attached?
      resource.exports.each do |export_doc|
        documents << {
          id: export_doc.blob.id,
          url: export_doc.blob.service.url(
            export_doc.blob.key,
            expires_in: 1.hour.to_i,
            filename: export_doc.blob.filename,
            disposition: 'attachment',
            content_type: export_doc.blob.content_type
          ),
          filename: export_doc.filename.to_s,
          created_at: export_doc.created_at,
          type: "export"
        }
      end
    end

    if resource.family.exports.attached?
      resource.family.exports.each do |export_doc|
        documents << {
          id: export_doc.blob.id,
          url: export_doc.blob.service.url(
            export_doc.blob.key,
            expires_in: 1.hour.to_i,
            filename: export_doc.blob.filename,
            disposition: 'attachment',
            content_type: export_doc.blob.content_type
          ),
          filename: export_doc.filename.to_s,
          created_at: export_doc.created_at,
          type: "export"
        }
      end
    end

    documents
  end

  def resource_params
    params.require(:data).require(:attributes).permit(:first_name, :last_name, :date_of_birth, :date_of_death, :deceased)
  end

  def update_params
    raw_attributes = params.require(:data).require(:attributes).to_unsafe_h
    transformed = raw_attributes.transform_keys { |key| key.tr('-', '_') }
    ActionController::Parameters.new(transformed).permit(
      :first_name,
      :last_name,
      :short_description,
      :birth_last_name,
      :birth_place,
      :birth_time,
      :date_of_birth,
      :gender,
      :religion,
      :profession,
      :deceased,
      :date_of_death,
      :death_time,
      :death_place,
      :cause_of_death,
      :burial_date,
      :burial_place,
      :internment_place,
      :hobbies_and_interests,
      :short_message
    )
  end

  def compress_image(image_data, max_width: 1024, quality: 80)
    image = MiniMagick::Image.read(image_data)
    image.resize "#{max_width}x#{max_width}>"
    image.quality quality.to_s
    image.to_blob
  end
end
