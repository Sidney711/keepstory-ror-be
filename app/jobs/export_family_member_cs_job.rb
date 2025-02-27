class ExportFamilyMemberCsJob < ApplicationJob
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
      image_data = Base64.strict_encode64(family_member.profile_picture.download)
      profile_picture_tag = "<img src='data:#{family_member.profile_picture.content_type};base64,#{image_data}' alt='Profile Picture' style='max-width:300px; display:block; margin-bottom:15px;'/>"
    end

    signature_tag = ""
    if family_member.signature.attached?
      sig_data = Base64.strict_encode64(family_member.signature.download)
      signature_tag = "<img src='data:#{family_member.signature.content_type};base64,#{sig_data}' alt='Signature' style='max-width:200px; max-height:100px; display:block; margin-top:15px;'/>"
    end

    personal_items = []
    personal_items << "<li><strong>Jméno:</strong> #{family_member.first_name} #{family_member.last_name}</li>"
    personal_items << "<li><strong>Rodné příjmení:</strong> #{family_member.birth_last_name}</li>" if family_member.birth_last_name.present?
    personal_items << "<li><strong>Datum narození:</strong> #{family_member.date_of_birth.strftime('%d.%m.%Y')}</li>" if family_member.date_of_birth.present?
    personal_items << "<li><strong>Místo narození:</strong> #{family_member.birth_place}</li>" if family_member.birth_place.present?
    personal_items << "<li><strong>Čas narození:</strong> #{family_member.birth_time.strftime('%H:%M')}</li>" if family_member.birth_time.present?
    if family_member.gender.present?
      gender_text = case family_member.gender
                    when "male" then "Muž"
                    when "female" then "Žena"
                    else "Ostatní"
                    end
      personal_items << "<li><strong>Pohlaví:</strong> #{gender_text}</li>"
    end
    personal_items << "<li><strong>Víra:</strong> #{family_member.religion}</li>" if family_member.religion.present?
    personal_items << "<li><strong>Povolání:</strong> #{family_member.profession}</li>" if family_member.profession.present?
    personal_items << "<li><strong>Zájmy:</strong> #{family_member.hobbies_and_interests}</li>" if family_member.hobbies_and_interests.present?
    personal_items << "<li><strong>Popis:</strong> #{family_member.short_description}</li>" if family_member.short_description.present?
    personal_items << "<li><strong>Zpráva:</strong> #{family_member.short_message}</li>" if family_member.short_message.present?

    personal_info = ""
    if personal_items.any?
      personal_info = <<~HTML
        <h3>Osobní informace</h3>
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
      death_items << "<li><strong>Datum úmrtí:</strong> #{family_member.date_of_death.strftime('%d.%m.%Y')}</li>" if family_member.date_of_death.present?
      death_items << "<li><strong>Čas úmrtí:</strong> #{family_member.death_time.strftime('%H:%M')}</li>" if family_member.death_time.present?
      death_items << "<li><strong>Místo úmrtí:</strong> #{family_member.death_place}</li>" if family_member.death_place.present?
      death_items << "<li><strong>Příčina úmrtí:</strong> #{family_member.cause_of_death}</li>" if family_member.cause_of_death.present?
      death_items << "<li><strong>Datum pohřbu:</strong> #{family_member.burial_date.strftime('%d.%m.%Y')}</li>" if family_member.burial_date.present?
      death_items << "<li><strong>Místo pohřbu:</strong> #{family_member.burial_place}</li>" if family_member.burial_place.present?
      death_items << "<li><strong>Místo internace:</strong> #{family_member.internment_place}</li>" if family_member.internment_place.present?
      if death_items.any?
        death_info = <<~HTML
          <h3>Údaje o úmrtí</h3>
          <ul>
            #{death_items.join("\n")}
          </ul>
        HTML
      end
    end

    parent_info = ""
    if family_member.father.present?
      parent_info += <<~HTML
        <h3>Otec</h3>
        <p>#{family_member.father.first_name} #{family_member.father.last_name}</p>
      HTML
    end
    if family_member.mother.present?
      parent_info += <<~HTML
        <h3>Matka</h3>
        <p>#{family_member.mother.first_name} #{family_member.mother.last_name}</p>
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
      siblings_html = "<h3>Sourozenci</h3>" + siblings.map do |sibling|
        li_date = sibling.date_of_birth.present? ? sibling.date_of_birth.strftime('%d.%m.%Y') : nil
        content = "<p><strong>Jméno:</strong> #{sibling.first_name} #{sibling.last_name}</p>"
        content << "<p><strong>Datum narození:</strong> #{li_date}</p>" if li_date
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
      grandparents_html = "<h3>Prarodiče</h3>" + grandparents.map do |grandparent|
        li_date = grandparent.date_of_birth.present? ? grandparent.date_of_birth.strftime('%d.%m.%Y') : nil
        content = "<p><strong>Jméno:</strong> #{grandparent.first_name} #{grandparent.last_name}</p>"
        content << "<p><strong>Datum narození:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    children = family_member.children
    children_html = ""
    if children.any?
      children_html = "<h3>Potomci</h3>" + children.map do |child|
        li_date = child.date_of_birth.present? ? child.date_of_birth.strftime('%d.%m.%Y') : nil
        content = "<p><strong>Jméno:</strong> #{child.first_name} #{child.last_name}</p>"
        content << "<p><strong>Datum narození:</strong> #{li_date}</p>" if li_date
        "<div class='card'>#{content}</div>"
      end.join
    end

    educations_html = ""
    if educations.any?
      educations_html = "<h3>Vzdělání</h3>" + educations.map do |edu|
        content = ""
        content << "<p><strong>Škola:</strong> #{edu.school_name}</p>" if edu.school_name.present?
        content << "<p><strong>Adresa:</strong> #{edu.address}</p>" if edu.address.present?
        content << "<p><strong>Období:</strong> #{edu.period}</p>" if edu.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    employments_html = ""
    if employments.any?
      employments_html = "<h3>Zaměstnání</h3>" + employments.map do |emp|
        content = ""
        content << "<p><strong>Zaměstnavatel:</strong> #{emp.employer}</p>" if emp.employer.present?
        content << "<p><strong>Adresa:</strong> #{emp.address}</p>" if emp.address.present?
        content << "<p><strong>Období:</strong> #{emp.period}</p>" if emp.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    residences_html = ""
    if residences.any?
      residences_html = "<h3>Adresa bydliště</h3>" + residences.map do |res|
        content = ""
        content << "<p><strong>Adresa:</strong> #{res.address}</p>" if res.address.present?
        content << "<p><strong>Období:</strong> #{res.period}</p>" if res.period.present?
        "<div class='card'>#{content}</div>" if content.present?
      end.join
    end

    additional_attrs_html = ""
    if additional_attrs.any?
      additional_attrs_html = "<h3>Další informace</h3>" + additional_attrs.map do |attr|
        if attr.attribute_name.present? && attr.long_text.present?
          "<div class='card'><p><strong>#{attr.attribute_name}:</strong> #{attr.long_text}</p></div>"
        end
      end.join
    end

    marriages_html = ""
    if marriages.any?
      marriages_html = "<h3>Manželství</h3>" + marriages.map do |m|
        partner = m.first_partner_id == family_member.id ? m.second_partner : m.first_partner
        if partner.present? && partner.first_name.present? && partner.last_name.present?
          "<div class='card'>
             <p><strong>Partner:</strong> #{partner.first_name} #{partner.last_name}</p>
             #{"<p><strong>Období:</strong> #{m.period}</p>" if m.period.present?}
           </div>"
        end
      end.join
    end

    stories_html = ""
    if stories.any?
      stories_html = "<div class='gallery-h'><h3>Příběhy</h3></div><div class='stories-section'>" + stories.map do |story|
        date_info = story.story_date.present? ? story.story_date.strftime('%d.%m.%Y') : (story.story_year.to_s if story.story_year.present?)
        "<div class='story'>
           <h3 class='story-title'><strong>#{story.title}</strong> #{"(#{date_info})" if date_info}</h3>
           <div class='story-content'>#{story.content}</div>
         </div><div class='page-break'></div>"
      end.join + "</div>"
    end

    gallery_html = ""
    if family_member.images.attached?
      gallery_html = "<div class='gallery-h'><h3>Galerie</h3></div><div class='gallery'>"
      family_member.images.each do |image|
        img_data = Base64.strict_encode64(image.download)
        gallery_html << "<div class='gallery-item'><img src='data:#{image.content_type};base64,#{img_data}' alt='Gallery Image' /></div>"
      end
      gallery_html << "</div>"
    end

    family_tree_svg = <<~SVG
      <div class='family-tree' style='text-align:center; margin:0px auto;'>
        <svg width="800" height="300" xmlns="http://www.w3.org/2000/svg">
          <style>
            .box { fill: #fff; stroke: #000; stroke-width: 1; }
            .current { fill: #ffff99; stroke: #000; stroke-width: 2; }
            .label { font-family: Arial, sans-serif; font-size: 12px; text-anchor: middle; dominant-baseline: central; }
          </style>
          <rect x="50" y="0" width="150" height="50" class="box"/>
          <text x="125" y="25" class="label">#{family_member.mother&.mother ? "#{family_member.mother.mother.first_name} #{family_member.mother.mother.last_name}" : ""}</text>
          <rect x="250" y="0" width="150" height="50" class="box"/>
          <text x="325" y="25" class="label">#{family_member.mother&.father ? "#{family_member.mother.father.first_name} #{family_member.mother.father.last_name}" : ""}</text>
          <rect x="450" y="0" width="150" height="50" class="box"/>
          <text x="525" y="25" class="label">#{family_member.father&.mother ? "#{family_member.father.mother.first_name} #{family_member.father.mother.last_name}" : ""}</text>
          <rect x="650" y="0" width="150" height="50" class="box"/>
          <text x="725" y="25" class="label">#{family_member.father&.father ? "#{family_member.father.father.first_name} #{family_member.father.father.last_name}" : ""}</text>
          <rect x="150" y="100" width="150" height="50" class="box"/>
          <text x="225" y="125" class="label">#{family_member.mother ? "#{family_member.mother.first_name} #{family_member.mother.last_name}" : ""}</text>
          <rect x="550" y="100" width="150" height="50" class="box"/>
          <text x="625" y="125" class="label">#{family_member.father ? "#{family_member.father.first_name} #{family_member.father.last_name}" : ""}</text>
          <rect x="350" y="200" width="150" height="50" class="current"/>
          <text x="425" y="225" class="label">#{family_member.first_name} #{family_member.last_name}</text>
          <line x1="125" y1="50" x2="225" y2="100" stroke="#000"/>
          <line x1="325" y1="50" x2="225" y2="100" stroke="#000"/>
          <line x1="525" y1="50" x2="625" y2="100" stroke="#000"/>
          <line x1="725" y1="50" x2="625" y2="100" stroke="#000"/>
          <line x1="225" y1="150" x2="425" y2="200" stroke="#000"/>
          <line x1="625" y1="150" x2="425" y2="200" stroke="#000"/>
        </svg>
      </div>
    SVG

    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Rodinná kniha</title>
        <style>
          @page { margin: 40px; size: A4; }
          body {
            font-family: 'Georgia', serif;
            background: #ffffff;
            margin: 0;
            padding: 0;
            color: #000;
            line-height: 1.6;
          }
          h1 { font-size: 32px; font-weight: bold; margin: 20px 0 10px; }
          h2 { font-size: 28px; font-weight: bold; margin: 18px 0 9px; }
          h3 { font-size: 24px; font-weight: bold; margin: 16px 0 8px; }
          h4 { font-size: 20px; font-weight: bold; margin: 14px 0 7px; }
          h5 { font-size: 18px; font-weight: bold; margin: 12px 0 6px; }
          h6 { font-size: 16px; font-weight: bold; margin: 10px 0 5px; }
          .cover {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 1122px;
            text-align: center;
            page-break-after: always;
          }
          .cover h1 {
            font-size: 32px;
            margin: 0;
          }
          .cover h2 {
            font-size: 28px;
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
            <h1>Paměti osoby</h1>
            <h2>#{family_member.first_name} #{family_member.last_name}</h2>
          </div>
        </div>
        <div class="details">
          #{personal_info}
          #{family_tree_svg}
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
    filename  = "export_clena_rodiny_#{timestamp}.pdf"
    io        = StringIO.new(pdf)
    family_member.exports.attach(
      io: io,
      filename: filename,
      content_type: 'application/pdf'
    )
    ExportMailer.export_member_ready_cs_email(family_member).deliver_later
  end
end
