class ExportFamilyMemberJob < ApplicationJob
  queue_as :default

  def perform(family_member_id)
    family_member = FamilyMember.find(family_member_id)
    stories = family_member.stories

    birth_info = family_member.date_of_birth.present? ? "<p>Narozen: #{family_member.date_of_birth.strftime('%d.%m.%Y')}</p>" : ""
    death_info = family_member.date_of_death.present? ? "<p>Zemřel: #{family_member.date_of_death.strftime('%d.%m.%Y')}</p>" : ""

    stories_html = stories.map do |story|
      date_info = story.story_date.present? ? story.story_date.strftime('%d.%m.%Y') : story.story_year.to_s
      "<div class='story'>
         <div class='story-title'>#{story.title} (#{date_info})</div>
         <div class='story-content'>#{story.content}</div>
       </div>"
    end.join

    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Rodinný příběh: #{family_member.first_name} #{family_member.last_name}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          .header { text-align: center; margin-bottom: 30px; }
          .story { margin-bottom: 20px; border-bottom: 1px solid #ccc; padding-bottom: 10px; }
          .story-title { font-size: 18px; font-weight: bold; }
          .story-content { font-size: 14px; margin-top: 5px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Rodinné příběhy</h1>
          <h2>#{family_member.first_name} #{family_member.last_name}</h2>
          #{birth_info}
          #{death_info}
        </div>
        #{stories_html}
      </body>
      </html>
    HTML

    pdf = WickedPdf.new.pdf_from_string(html)

    output_path = Rails.root.join('tmp', 'pdfs')
    FileUtils.mkdir_p(output_path) unless File.directory?(output_path)
    file_path = output_path.join("family_member_#{family_member.id}.pdf")
    File.open(file_path, 'wb') do |file|
      file.write(pdf)
    end
  end
end
