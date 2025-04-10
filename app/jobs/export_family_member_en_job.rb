class ExportFamilyMemberEnJob < ApplicationJob
  queue_as :default

  def perform(family_member_id)
    family_member = FamilyMember.find(family_member_id)
    stories          = family_member.stories
    educations       = family_member.educations
    employments      = family_member.employments
    residences       = family_member.residence_addresses
    additional_attrs = family_member.additional_attributes
    marriages        = Marriage.where("first_partner_id = ? OR second_partner_id = ?", family_member.id, family_member.id)

    profile_picture_tag = ""
    if family_member.profile_picture.attached?
      original_data = family_member.profile_picture.download
      compressed_data = compress_image(original_data, max_width: 500, quality: 50)
      encoded_image = Base64.strict_encode64(compressed_data)
      profile_picture_tag = "<img src='data:#{family_member.profile_picture.content_type};base64,#{encoded_image}' alt='Profile Picture' style='max-width:300px; display:block; margin-bottom:15px;'/>"
    end

    signature_tag = ""
    if family_member.signature.attached?
      original_sig = family_member.signature.download
      compressed_sig = compress_image(original_sig, max_width: 500, quality: 50)
      sig_data = Base64.strict_encode64(compressed_sig)
      signature_tag = "<img src='data:#{family_member.signature.content_type};base64,#{sig_data}' alt='Signature' style='max-width:200px; max-height:100px; display:block; margin-top:15px;'/>"
    end

    personal_items = []
    personal_items << "<li><strong>Name:</strong> #{ERB::Util.html_escape(family_member.first_name)} #{ERB::Util.html_escape(family_member.last_name)}</li>"
    personal_items << "<li><strong>Birth Surname:</strong> #{ERB::Util.html_escape(family_member.birth_last_name)}</li>" if family_member.birth_last_name.present?
    personal_items << "<li><strong>Date of Birth:</strong> #{ERB::Util.html_escape(family_member.date_of_birth.strftime('%d.%m.%Y'))}</li>" if family_member.date_of_birth.present?
    personal_items << "<li><strong>Place of Birth:</strong> #{ERB::Util.html_escape(family_member.birth_place)}</li>" if family_member.birth_place.present?
    personal_items << "<li><strong>Time of Birth:</strong> #{ERB::Util.html_escape(family_member.birth_time.strftime('%H:%M'))}</li>" if family_member.birth_time.present?
    if family_member.gender.present?
      gender_text = case family_member.gender
                    when "male" then "Male"
                    when "female" then "Female"
                    else "Other"
                    end
      personal_items << "<li><strong>Gender:</strong> #{ERB::Util.html_escape(gender_text)}</li>"
    end
    personal_items << "<li><strong>Religion:</strong> #{ERB::Util.html_escape(family_member.religion)}</li>" if family_member.religion.present?
    personal_items << "<li><strong>Profession:</strong> #{ERB::Util.html_escape(family_member.profession)}</li>" if family_member.profession.present?
    personal_items << "<li><strong>Hobbies:</strong> #{ERB::Util.html_escape(family_member.hobbies_and_interests)}</li>" if family_member.hobbies_and_interests.present?
    personal_items << "<li><strong>Description:</strong> #{ERB::Util.html_escape(family_member.short_description)}</li>" if family_member.short_description.present?
    personal_items << "<li><strong>Message:</strong> #{ERB::Util.html_escape(family_member.short_message)}</li>" if family_member.short_message.present?

    personal_info = ""
    if personal_items.any?
      personal_info = <<~HTML
        <h3>Personal Information</h3>
        #{profile_picture_tag}
        <ul>
          #{personal_items.join("\n")}
        </ul>
        #{signature_tag}
      HTML
    end

    death_info = ""
    if family_member.deceased
      death_items = []
      death_items << "<li><strong>Date of Death:</strong> #{ERB::Util.html_escape(family_member.date_of_death.strftime('%d.%m.%Y'))}</li>" if family_member.date_of_death.present?
      death_items << "<li><strong>Time of Death:</strong> #{ERB::Util.html_escape(family_member.death_time.strftime('%H:%M'))}</li>" if family_member.death_time.present?
      death_items << "<li><strong>Place of Death:</strong> #{ERB::Util.html_escape(family_member.death_place)}</li>" if family_member.death_place.present?
      death_items << "<li><strong>Cause of Death:</strong> #{ERB::Util.html_escape(family_member.cause_of_death)}</li>" if family_member.cause_of_death.present?
      death_items << "<li><strong>Date of Burial:</strong> #{ERB::Util.html_escape(family_member.burial_date.strftime('%d.%m.%Y'))}</li>" if family_member.burial_date.present?
      death_items << "<li><strong>Place of Burial:</strong> #{ERB::Util.html_escape(family_member.burial_place)}</li>" if family_member.burial_place.present?
      death_items << "<li><strong>Place of Interment:</strong> #{ERB::Util.html_escape(family_member.internment_place)}</li>" if family_member.internment_place.present?
      if death_items.any?
        death_info = <<~HTML
          <h3>Death Details</h3>
          <ul>
            #{death_items.join("\n")}
          </ul>
        HTML
      end
    end

    parent_info = ""
    if family_member.father.present?
      parent_info += <<~HTML
        <h3>Father</h3>
        <p>#{ERB::Util.html_escape(family_member.father.first_name)} #{ERB::Util.html_escape(family_member.father.last_name)}</p>
      HTML
    end
    if family_member.mother.present?
      parent_info += <<~HTML
        <h3>Mother</h3>
        <p>#{ERB::Util.html_escape(family_member.mother.first_name)} #{ERB::Util.html_escape(family_member.mother.last_name)}</p>
      HTML
    end

    siblings = if family_member.mother_id.present? || family_member.father_id.present?
                 scopes = []
                 scopes << FamilyMember.where(mother_id: family_member.mother_id) if family_member.mother_id.present?
                 scopes << FamilyMember.where(father_id: family_member.father_id) if family_member.father_id.present?
                 scopes.inject(FamilyMember.none) { |combined, scope| combined.or(scope) }
                   .where.not(id: family_member.id)
               else
                 FamilyMember.none
               end

    siblings_html = ""
    if siblings.any?
      siblings_html = "<h3>Siblings</h3>" + siblings.map do |sibling|
        li_date = sibling.date_of_birth.present? ? ERB::Util.html_escape(sibling.date_of_birth.strftime('%d.%m.%Y')) : nil
        content = "<p><strong>Name:</strong> #{ERB::Util.html_escape(sibling.first_name)} #{ERB::Util.html_escape(sibling.last_name)}</p>"
        content << "<p><strong>Date of Birth:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    grandparents = []
    grandparents << family_member.mother.mother if family_member.mother&.mother
    grandparents << family_member.mother.father if family_member.mother&.father
    grandparents << family_member.father.mother if family_member.father&.mother
    grandparents << family_member.father.father if family_member.father&.father

    grandparents_html = ""
    if grandparents.any?
      grandparents_html = "<h3>Grandparents</h3>" + grandparents.map do |grandparent|
        li_date = grandparent.date_of_birth.present? ? ERB::Util.html_escape(grandparent.date_of_birth.strftime('%d.%m.%Y')) : nil
        content = "<p><strong>Name:</strong> #{ERB::Util.html_escape(grandparent.first_name)} #{ERB::Util.html_escape(grandparent.last_name)}</p>"
        content << "<p><strong>Date of Birth:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    children = family_member.children
    children_html = ""
    if children.any?
      children_html = "<h3>Children</h3>" + children.map do |child|
        li_date = child.date_of_birth.present? ? ERB::Util.html_escape(child.date_of_birth.strftime('%d.%m.%Y')) : nil
        content = "<p><strong>Name:</strong> #{ERB::Util.html_escape(child.first_name)} #{ERB::Util.html_escape(child.last_name)}</p>"
        content << "<p><strong>Date of Birth:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    educations_html = ""
    if educations.any?
      educations_html = "<h3>Education</h3>" + educations.map do |edu|
        content = ""
        content << "<p><strong>School:</strong> #{ERB::Util.html_escape(edu.school_name)}</p>" if edu.school_name.present?
        content << "<p><strong>Address:</strong> #{ERB::Util.html_escape(edu.address)}</p>" if edu.address.present?
        content << "<p><strong>Period:</strong> #{ERB::Util.html_escape(edu.period)}</p>" if edu.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    employments_html = ""
    if employments.any?
      employments_html = "<h3>Employment</h3>" + employments.map do |emp|
        content = ""
        content << "<p><strong>Employer:</strong> #{ERB::Util.html_escape(emp.employer)}</p>" if emp.employer.present?
        content << "<p><strong>Address:</strong> #{ERB::Util.html_escape(emp.address)}</p>" if emp.address.present?
        content << "<p><strong>Period:</strong> #{ERB::Util.html_escape(emp.period)}</p>" if emp.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    residences_html = ""
    if residences.any?
      residences_html = "<h3>Residence Address</h3>" + residences.map do |res|
        content = ""
        content << "<p><strong>Address:</strong> #{ERB::Util.html_escape(res.address)}</p>" if res.address.present?
        content << "<p><strong>Period:</strong> #{ERB::Util.html_escape(res.period)}</p>" if res.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    additional_attrs_html = ""
    if additional_attrs.any?
      additional_attrs_html = "<h3>Additional Information</h3>" + additional_attrs.map do |attr|
        if attr.attribute_name.present? && attr.long_text.present?
          "<div class='card'><p><strong>#{ERB::Util.html_escape(attr.attribute_name)}:</strong> #{ERB::Util.html_escape(attr.long_text)}</p></div>"
        end
      end.join
    end

    marriages_html = ""
    if marriages.any?
      marriages_html = "<h3>Marriages</h3>" + marriages.map do |m|
        partner = m.first_partner_id == family_member.id ? m.second_partner : m.first_partner
        if partner.present? && partner.first_name.present? && partner.last_name.present?
          "<div class='card'>
             <p><strong>Partner:</strong> #{ERB::Util.html_escape(partner.first_name)} #{ERB::Util.html_escape(partner.last_name)}</p>
             #{"<p><strong>Period:</strong> #{ERB::Util.html_escape(m.period)}</p>" if m.period.present?}
           </div>"
        end
      end.join
    end

    stories_html = ""
    if stories.any?
      stories_html = "<div class='gallery-h'><h3>Stories</h3></div><div class='stories-section'>" + stories.map do |story|
        date_info = story.story_date.present? ? ERB::Util.html_escape(story.story_date.strftime('%d.%m.%Y')) : (ERB::Util.html_escape(story.story_year.to_s) if story.story_year.present?)
        "<div class='story'>
           <h3 class='story-title'><strong>#{ERB::Util.html_escape(story.title)}</strong> #{"(#{date_info})" if date_info}</h3>
           <div class='story-content'>#{story.content}</div>
         </div><div class='page-break'></div>"
      end.join + "</div>"
    end

    gallery_html = ""
    if family_member.images.attached?
      gallery_html = "<div class='gallery-h'><h3>Gallery</h3></div><div class='gallery'>"
      family_member.images.each do |image|
        original_img = image.download
        compressed_img = compress_image(original_img, max_width: 500, quality: 50)
        img_data = Base64.strict_encode64(compressed_img)
        gallery_html << "<div class='gallery-item'><img src='data:#{image.content_type};base64,#{img_data}' alt='Gallery Image' /></div>"
      end
      gallery_html << "</div>"
    end

    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Family Book</title>
        <style>
          @page { margin: 40px; size: A4; }
          body {
            font-family: 'Georgia', serif;
            background: #ffffff;
            margin: 0;
            padding: 0;
            color: #000;
            line-height: 1.6;
            font-size: 16px;
          }
          h1 { font-size: 35px; font-weight: bold; margin: 20px 0 10px; }
          h2 { font-size: 31px; font-weight: bold; margin: 18px 0 9px; }
          h3 { font-size: 27px; font-weight: bold; margin: 16px 0 8px; }
          h4 { font-size: 23px; font-weight: bold; margin: 14px 0 7px; }
          h5 { font-size: 21px; font-weight: bold; margin: 12px 0 6px; }
          h6 { font-size: 19px; font-weight: bold; margin: 10px 0 5px; }
          .cover {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 1122px;
            text-align: center;
            page-break-after: always;
          }
          .cover h1 {
            font-size: 52px;
            margin: 0;
          }
          .cover h2 {
            font-size: 45px;
            margin: 10px 0 0;
            font-weight: normal;
          }
          .details {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            page-break-after: always;
          }
          .gallery-h {
            max-width: 800px;
            margin: 40px auto;
          }
          .gallery-h h3 {
            border-bottom: 1px solid #000;
          }
          .details h3 {
            border-bottom: 1px solid #000;
            padding-bottom: 5px;
            margin-top: 20px;
          }
          .details ul {
            list-style: none;
            padding: 0;
          }
          .details li {
            margin: 5px 0;
          }
          .card {
            padding-bottom: 15px;
          }
          .stories-section {
            padding: 30px 80px;
          }
          .page-break { page-break-after: always; }
          footer {
            text-align: center;
            font-size: 12px;
            color: #000;
            margin-top: 30px;
          }
          .story-content h1 { font-size: 22px; font-weight: bold; margin: 10px 0 0; }
          .story-content h2 { font-size: 18px; font-weight: bold; margin: 8px 0 0; }
          .story-content h3 { font-size: 14px; font-weight: bold; margin: 6px 0 0; }
          .story-content h4 { font-size: 11px; font-weight: bold; margin: 4px 0 0; }
          .story-content h5 { font-size: 8px; font-weight: bold; margin: 2px 0 0; }
          .story-content h6 { font-size: 6px; font-weight: bold; margin: 0; }
          .gallery {
            text-align: center;
            margin-top: 20px;
          }
          .gallery-item {
            display: inline-block;
            vertical-align: top;
            width: 400px;
            margin: 5px;
            overflow: hidden;
          }
          .gallery-item img {
            width: 400px;
            height: auto;
            display: block;
          }
          .family-tree {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
          }
        </style>
      </head>
      <body>
        <div class="cover">
          <div>
            <h1>Personal Memories</h1>
            <h2>#{ERB::Util.html_escape(family_member.first_name)} #{ERB::Util.html_escape(family_member.last_name)}</h2>
          </div>
        </div>
        <div class="details">
          #{personal_info}
          #{death_info}
          #{parent_info}
          #{siblings_html}
          #{grandparents_html}
          #{children_html}
          #{marriages_html}
          #{educations_html}
          #{employments_html}
          #{residences_html}
          #{additional_attrs_html}
        </div>
        #{stories_html}
        #{gallery_html}
      </body>
      </html>
    HTML

    pdf       = WickedPdf.new.pdf_from_string(html)
    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    filename  = "export_family_member_#{timestamp}.pdf"
    io        = StringIO.new(pdf)
    family_member.exports.attach(
      io: io,
      filename: filename,
      content_type: 'application/pdf'
    )
    ExportMailer.export_member_ready_en_email(family_member).deliver_later
  end

  private

  def compress_image(image_data, max_width: 1024, quality: 80)
    image = MiniMagick::Image.read(image_data)
    image.resize "#{max_width}x#{max_width}>"
    image.quality quality.to_s
    image.to_blob
  end
end
