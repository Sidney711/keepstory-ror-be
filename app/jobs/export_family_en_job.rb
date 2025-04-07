class ExportFamilyEnJob < ApplicationJob
  queue_as :default

  def perform(family_id)
    family = Family.find(family_id)
    members = family.family_members.includes(
      :stories, :educations, :employments, :residence_addresses,
      :additional_attributes, :profile_picture_attachment,
      :signature_attachment, :father, :mother
    )

    members_html = members.map { |member| render_member(member) }.join

    title_html = <<~HTML
      <div class="cover">
        <div>
          <h1>Our Family</h1>
        </div>
      </div>
    HTML

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
          .cover {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 1122px;
            text-align: center;
            page-break-after: always;
          }
          .cover h1 { font-size: 52px; margin: 0; }
          .cover h2 { font-size: 45px; margin: 10px 0 0; font-weight: normal; }
          .cover p { font-size: 16px; margin: 5px 0; }
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
        #{title_html}
        #{members_html}
      </body>
      </html>
    HTML

    pdf       = WickedPdf.new.pdf_from_string(html)
    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    filename  = "export_family_#{timestamp}.pdf"
    io        = StringIO.new(pdf)
    family.exports.attach(
      io: io,
      filename: filename,
      content_type: 'application/pdf'
    )
    ExportMailer.export_family_ready_en_email(family).deliver_later
  end

  private

  def render_member(member)
    profile_picture_tag = ""
    if member.profile_picture.attached?
      image_data = Base64.strict_encode64(member.profile_picture.download)
      profile_picture_tag = "<img src='data:#{member.profile_picture.content_type};base64,#{image_data}' alt='Profile Picture' style='max-width:300px; display:block; margin-bottom:15px;'/>"
    end

    signature_tag = ""
    if member.signature.attached?
      sig_data = Base64.strict_encode64(member.signature.download)
      signature_tag = "<img src='data:#{member.signature.content_type};base64,#{sig_data}' alt='Signature' style='max-width:200px; max-height:100px; display:block; margin-top:15px;'/>"
    end

    personal_items = []
    personal_items << "<li><strong>Name:</strong> #{member.first_name} #{member.last_name}</li>"
    personal_items << "<li><strong>Birth Surname:</strong> #{member.birth_last_name}</li>" if member.birth_last_name.present?
    personal_items << "<li><strong>Date of Birth:</strong> #{member.date_of_birth.strftime('%d.%m.%Y')}</li>" if member.date_of_birth.present?
    personal_items << "<li><strong>Place of Birth:</strong> #{member.birth_place}</li>" if member.birth_place.present?
    personal_items << "<li><strong>Time of Birth:</strong> #{member.birth_time.strftime('%H:%M')}</li>" if member.birth_time.present?
    if member.gender.present?
      gender_text = case member.gender
                    when "male" then "Male"
                    when "female" then "Female"
                    else "Other"
                    end
      personal_items << "<li><strong>Gender:</strong> #{gender_text}</li>"
    end
    personal_items << "<li><strong>Religion:</strong> #{member.religion}</li>" if member.religion.present?
    personal_items << "<li><strong>Profession:</strong> #{member.profession}</li>" if member.profession.present?
    personal_items << "<li><strong>Hobbies and Interests:</strong> #{member.hobbies_and_interests}</li>" if member.hobbies_and_interests.present?
    personal_items << "<li><strong>Description:</strong> #{member.short_description}</li>" if member.short_description.present?
    personal_items << "<li><strong>Message:</strong> #{member.short_message}</li>" if member.short_message.present?

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
    if member.deceased
      death_items = []
      death_items << "<li><strong>Date of Death:</strong> #{member.date_of_death.strftime('%d.%m.%Y')}</li>" if member.date_of_death.present?
      death_items << "<li><strong>Time of Death:</strong> #{member.death_time.strftime('%H:%M')}</li>" if member.death_time.present?
      death_items << "<li><strong>Place of Death:</strong> #{member.death_place}</li>" if member.death_place.present?
      death_items << "<li><strong>Cause of Death:</strong> #{member.cause_of_death}</li>" if member.cause_of_death.present?
      death_items << "<li><strong>Date of Burial:</strong> #{member.burial_date.strftime('%d.%m.%Y')}</li>" if member.burial_date.present?
      death_items << "<li><strong>Place of Burial:</strong> #{member.burial_place}</li>" if member.burial_place.present?
      death_items << "<li><strong>Place of Interment:</strong> #{member.internment_place}</li>" if member.internment_place.present?
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
    if member.father.present?
      parent_info += <<~HTML
        <h3>Father</h3>
        <p>#{member.father.first_name} #{member.father.last_name}</p>
      HTML
    end
    if member.mother.present?
      parent_info += <<~HTML
        <h3>Mother</h3>
        <p>#{member.mother.first_name} #{member.mother.last_name}</p>
      HTML
    end

    siblings = if member.mother_id.present? || member.father_id.present?
                 scopes = []
                 scopes << FamilyMember.where(mother_id: member.mother_id) if member.mother_id.present?
                 scopes << FamilyMember.where(father_id: member.father_id) if member.father_id.present?
                 scopes.inject(FamilyMember.none) { |combined, scope| combined.or(scope) }
                   .where.not(id: member.id)
               else
                 FamilyMember.none
               end

    siblings_html = ""
    if siblings.any?
      siblings_html = "<h3>Siblings</h3>" + siblings.map do |sibling|
        li_date = sibling.date_of_birth.present? ? sibling.date_of_birth.strftime('%d.%m.%Y') : nil
        content = "<p><strong>Name:</strong> #{sibling.first_name} #{sibling.last_name}</p>"
        content << "<p><strong>Date of Birth:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    grandparents = []
    grandparents << member.mother.mother if member.mother&.mother
    grandparents << member.mother.father if member.mother&.father
    grandparents << member.father.mother if member.father&.mother
    grandparents << member.father.father if member.father&.father

    grandparents_html = ""
    if grandparents.any?
      grandparents_html = "<h3>Grandparents</h3>" + grandparents.map do |grandparent|
        li_date = grandparent.date_of_birth.present? ? grandparent.date_of_birth.strftime('%d.%m.%Y') : nil
        content = "<p><strong>Name:</strong> #{grandparent.first_name} #{grandparent.last_name}</p>"
        content << "<p><strong>Date of Birth:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    educations = member.educations
    educations_html = ""
    if educations.any?
      educations_html = "<h3>Education</h3>" + educations.map do |edu|
        content = ""
        content << "<p><strong>School:</strong> #{edu.school_name}</p>" if edu.school_name.present?
        content << "<p><strong>Address:</strong> #{edu.address}</p>" if edu.address.present?
        content << "<p><strong>Period:</strong> #{edu.period}</p>" if edu.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    employments = member.employments
    employments_html = ""
    if employments.any?
      employments_html = "<h3>Employment</h3>" + employments.map do |emp|
        content = ""
        content << "<p><strong>Employer:</strong> #{emp.employer}</p>" if emp.employer.present?
        content << "<p><strong>Address:</strong> #{emp.address}</p>" if emp.address.present?
        content << "<p><strong>Period:</strong> #{emp.period}</p>" if emp.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    residences = member.residence_addresses
    residences_html = ""
    if residences.any?
      residences_html = "<h3>Residence Address</h3>" + residences.map do |res|
        content = ""
        content << "<p><strong>Address:</strong> #{res.address}</p>" if res.address.present?
        content << "<p><strong>Period:</strong> #{res.period}</p>" if res.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    additional_attrs = member.additional_attributes
    additional_attrs_html = ""
    if additional_attrs.any?
      additional_attrs_html = "<h3>Additional Information</h3>" + additional_attrs.map do |attr|
        if attr.attribute_name.present? && attr.long_text.present?
          "<div class='card'><p><strong>#{attr.attribute_name}:</strong> #{attr.long_text}</p></div>"
        end
      end.join
    end

    marriages = Marriage.where("first_partner_id = ? OR second_partner_id = ?", member.id, member.id)
    marriages_html = ""
    if marriages.any?
      marriages_html = "<h3>Marriages</h3>" + marriages.map do |m|
        partner = m.first_partner_id == member.id ? m.second_partner : m.first_partner
        if partner.present? && partner.first_name.present? && partner.last_name.present?
          "<div class='card'>
             <p><strong>Partner:</strong> #{partner.first_name} #{partner.last_name}</p>
             #{"<p><strong>Period:</strong> #{m.period}</p>" if m.period.present?}
           </div>"
        end
      end.join
    end

    stories = member.stories
    stories_html = ""
    if stories.any?
      stories_html = "<div class='gallery-h'><h3>Stories</h3></div><div class='stories-section'>" + stories.map do |story|
        date_info = story.story_date.present? ? story.story_date.strftime('%d.%m.%Y') : (story.story_year.to_s if story.story_year.present?)
        <<~STORY
          <div class='story'>
             <h3 class='story-title'><strong>#{story.title}</strong> #{"(#{date_info})" if date_info}</h3>
             <div class='story-content'>#{story.content}</div>
          </div>
          <div class='page-break'></div>
        STORY
      end.join + "</div>"
    end

    gallery_html = ""
    if member.respond_to?(:images) && member.images.attached?
      gallery_html = "<div class='gallery-h'><h3>Gallery</h3></div><div class='gallery'>"
      member.images.each do |image|
        img_data = Base64.strict_encode64(image.download)
        gallery_html << "<div class='gallery-item'><img src='data:#{image.content_type};base64,#{img_data}' alt='Gallery Image' /></div>"
      end
      gallery_html << "</div>"
    end

    cover_html = <<~HTML
      <div class="cover">
        <div>
          #{profile_picture_tag}
          <h2>#{member.first_name} #{member.last_name}</h2>
          #{ member.date_of_birth.present? ? "<p>Date of Birth: #{member.date_of_birth.strftime('%d.%m.%Y')}</p>" : "" }
          #{ (member.deceased && member.date_of_death.present?) ? "<p>Date of Death: #{member.date_of_death.strftime('%d.%m.%Y')}</p>" : "" }
        </div>
      </div>
    HTML

    details_html = <<~HTML
      <div class="details">
        #{personal_info}
        #{death_info}
        #{parent_info}
        #{siblings_html}
        #{grandparents_html}
        #{marriages_html}
        #{educations_html}
        #{employments_html}
        #{residences_html}
        #{additional_attrs_html}
      </div>
    HTML

    member_section = <<~HTML
      #{cover_html}
      #{details_html}
      #{stories_html}
      #{gallery_html}
      <div class="page-break"></div>
    HTML

    member_section
  end
end
