class ExportFamilyMemberJob < ApplicationJob
  queue_as :default

  def perform(family_member_id)
    family_member = FamilyMember.find(family_member_id)
    stories = family_member.stories
    educations = family_member.educations
    employments = family_member.employments
    residences = family_member.residence_addresses
    additional_attrs = family_member.additional_attributes
    marriages = Marriage.where("first_partner_id = ? OR second_partner_id = ?", family_member.id, family_member.id)

    personal_info = <<~HTML
      <h3>Osobní informace</h3>
      <ul>
        <li><strong>Jméno:</strong> #{family_member.first_name} #{family_member.last_name}</li>
        <li><strong>Rodné příjmení:</strong> #{family_member.birth_last_name}</li>
        <li><strong>Datum narození:</strong> #{family_member.date_of_birth.present? ? family_member.date_of_birth.strftime('%d.%m.%Y') : "neuvedeno"}</li>
        <li><strong>Místo narození:</strong> #{family_member.birth_place}</li>
        <li><strong>Čas narození:</strong> #{family_member.birth_time.present? ? family_member.birth_time.strftime('%H:%M') : "neuvedeno"}</li>
        <li><strong>Pohlaví:</strong> #{family_member.gender == 1 ? "Muž" : family_member.gender == 2 ? "Žena" : "Other"}</li>
        <li><strong>Víra:</strong> #{family_member.religion}</li>
        <li><strong>Povolání:</strong> #{family_member.profession}</li>
        <li><strong>Zájmy:</strong> #{family_member.hobbies_and_interests}</li>
        <li><strong>Popis:</strong> #{family_member.short_description}</li>
        <li><strong>Zpráva:</strong> #{family_member.short_message}</li>
      </ul>
    HTML

    death_info = ""
    if family_member.deceased
      death_info = <<~HTML
        <h3>Údaje o úmrtí</h3>
        <ul>
          <li><strong>Datum úmrtí:</strong> #{family_member.death_date.present? ? family_member.death_date.strftime('%d.%m.%Y') : "neuvedeno"}</li>
          <li><strong>Čas úmrtí:</strong> #{family_member.death_time.present? ? family_member.death_time.strftime('%H:%M') : "neuvedeno"}</li>
          <li><strong>Místo úmrtí:</strong> #{family_member.death_place}</li>
          <li><strong>Příčina úmrtí:</strong> #{family_member.cause_of_death}</li>
          <li><strong>Datum pohřbu:</strong> #{family_member.burial_date.present? ? family_member.burial_date.strftime('%d.%m.%Y') : "neuvedeno"}</li>
          <li><strong>Místo pohřbu:</strong> #{family_member.burial_place}</li>
          <li><strong>Místo internace:</strong> #{family_member.internment_place}</li>
        </ul>
      HTML
    end

    parent_info = ""
    if family_member.father
      parent_info += <<~HTML
        <h3>Otec</h3>
        <p>#{family_member.father.first_name} #{family_member.father.last_name}</p>
      HTML
    end
    if family_member.mother
      parent_info += <<~HTML
        <h3>Matka</h3>
        <p>#{family_member.mother.first_name} #{family_member.mother.last_name}</p>
      HTML
    end

    educations_html = ""
    unless educations.empty?
      educations_html = "<h3>Vzdělání</h3>" + educations.map do |edu|
        "<div class='card'>
           <p><strong>Škola:</strong> #{edu.school_name}</p>
           <p><strong>Adresa:</strong> #{edu.address}</p>
           <p><strong>Období:</strong> #{edu.period}</p>
         </div>"
      end.join
    end

    employments_html = ""
    unless employments.empty?
      employments_html = "<h3>Zaměstnání</h3>" + employments.map do |emp|
        "<div class='card'>
           <p><strong>Zaměstnavatel:</strong> #{emp.employer}</p>
           <p><strong>Adresa:</strong> #{emp.address}</p>
           <p><strong>Období:</strong> #{emp.period}</p>
         </div>"
      end.join
    end

    residences_html = ""
    unless residences.empty?
      residences_html = "<h3>Adresa bydliště</h3>" + residences.map do |res|
        "<div class='card'>
           <p><strong>Adresa:</strong> #{res.address}</p>
           <p><strong>Období:</strong> #{res.period}</p>
         </div>"
      end.join
    end

    additional_attrs_html = ""
    unless additional_attrs.empty?
      additional_attrs_html = "<h3>Další atributy</h3>" + additional_attrs.map do |attr|
        "<div class='card'>
           <p><strong>Atribut:</strong> #{attr.attribute_name}</p>
           <p><strong>Popis:</strong> #{attr.long_text}</p>
         </div>"
      end.join
    end

    marriages_html = ""
    unless marriages.empty?
      marriages_html = "<h3>Manželství</h3>" + marriages.map do |m|
        partner = m.first_partner_id == family_member.id ? m.second_partner : m.first_partner
        "<div class='card'>
           <p><strong>Partner:</strong> #{partner.first_name} #{partner.last_name}</p>
           <p><strong>Období:</strong> #{m.period}</p>
         </div>"
      end.join
    end

    stories_html = ""
    unless stories.empty?
      stories_html = "<div class='stories-section'><h3>Příběhy</h3>" + stories.map do |story|
        date_info = story.story_date.present? ? story.story_date.strftime('%d.%m.%Y') : story.story_year.to_s
        "<div class='story'>
           <p class='story-title'><strong>#{story.title}</strong> (#{date_info})</p>
           <p class='story-content'>#{story.content}</p>
         </div><div class='page-break'></div>"
      end.join + "</div>"
    end

    summary_text = <<~HTML
      <div class="intro-summary">
        <h2>Úvod</h2>
        <p>
          Tato kniha představuje životní příběh osoby #{family_member.first_name} #{family_member.last_name}. 
          Narodil#{family_member.gender == 1 ? " se" : "a se"} dne #{family_member.date_of_birth.present? ? family_member.date_of_birth.strftime('%d.%m.%Y') : "neuvedeno"} v #{family_member.birth_place}, 
          a od mládí se vyznačoval#{family_member.gender == 1 ? "" : "a"} výrazným zájmem o #{family_member.hobbies_and_interests}. 
          Jeho#{family_member.gender == 1 ? "" : "in"} profesní dráha jako #{family_member.profession} a osobní zkušenosti, 
          včetně zásadních životních momentů, jsou zde pečlivě zaznamenány. 
          Následující stránky obsahují přehled o vzdělání, zaměstnání, rodinných vazbách a dalších důležitých událostech, 
          stejně jako vzpomínky a příběhy, které tvoří mozaiku jeho existence.
        </p>
      </div>
    HTML

    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Rodinná kniha: #{family_member.first_name} #{family_member.last_name}</title>
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
          /* Cover page styling: pevná výška místo 100vh */
          .cover {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 1122px; /* A4 výška v pixelech při 96 DPI, případně upravte dle potřeby */
            text-align: center;
            page-break-after: always;
          }
          .cover h1 {
            font-size: 70px;
            margin: 0;
            letter-spacing: 2px;
          }
          .cover h2 {
            font-size: 40px;
            margin: 20px 0 0;
            font-weight: normal;
          }
          /* Introduction page styling */
          .introduction {
            padding: 50px 80px;
            page-break-after: always;
          }
          .introduction h2 {
            font-size: 36px;
            margin-bottom: 20px;
            text-align: center;
          }
          .introduction p {
            font-size: 18px;
            text-align: justify;
          }
          /* Details page styling */
          .details {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            page-break-after: always;
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
            background: #f0f0f0;
            padding: 15px;
            margin: 15px 0;
            border-left: 5px solid #000;
            border-radius: 3px;
          }
          /* Stories section styling */
          .stories-section {
            padding: 30px 80px;
          }
          .stories-section h3 {
            margin-bottom: 20px;
            text-align: center;
            font-size: 32px;
          }
          .story {
            margin-bottom: 40px;
          }
          .story-title {
            font-size: 24px;
            margin-bottom: 10px;
          }
          .story-content {
            font-size: 18px;
            text-align: justify;
          }
          .page-break {
            page-break-after: always;
          }
          footer {
            text-align: center;
            font-size: 12px;
            color: #000;
            margin-top: 30px;
          }
        </style>
      </head>
      <body>
        <!-- Cover Page -->
        <div class="cover">
          <div>
            <h1>Paměti osoby</h1>
            <h2>#{family_member.first_name} #{family_member.last_name}</h2>
          </div>
        </div>
        <!-- Introduction Page -->
        <div class="introduction">
          #{summary_text}
        </div>
        <!-- Details Page -->
        <div class="details">
          #{personal_info}
          #{death_info}
          #{parent_info}
          #{educations_html}
          #{employments_html}
          #{residences_html}
          #{additional_attrs_html}
          #{marriages_html}
        </div>
        <!-- Stories Pages -->
        #{stories_html}
        <footer>
          Rodinná kniha vygenerována pomocí systému dne #{Time.current.strftime('%d.%m.%Y %H:%M')}
        </footer>
      </body>
      </html>
    HTML

    pdf = WickedPdf.new.pdf_from_string(html)
    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    filename = "family_member_#{family_member.id}_#{timestamp}.pdf"
    io = StringIO.new(pdf)
    family_member.documents.attach(
      io: io,
      filename: filename,
      content_type: 'application/pdf'
    )
    ExportMailer.export_member_ready_email(family_member).deliver_later
  end
end
