class ExportFamilyJob < ApplicationJob
  queue_as :default

  def perform(family_id)
    family = Family.find(family_id)
    members = family.family_members.includes(:stories)

    members_html = members.map do |member|
      birth_info = member.date_of_birth.present? ? "<p>Narozen: #{member.date_of_birth.strftime('%d.%m.%Y')}</p>" : ""
      death_info = member.date_of_death.present? ? "<p>Zemřel: #{member.date_of_death.strftime('%d.%m.%Y')}</p>" : ""

      stories_html = member.stories.map do |story|
        date_info = if story.story_date.present?
                      story.story_date.strftime('%d.%m.%Y')
                    elsif story.story_year.present?
                      story.story_year.to_s
                    else
                      ""
                    end

        <<~STORY
          <div class="story">
            <div class="story-title">#{story.title} (#{date_info})</div>
            <div class="story-content">#{story.content}</div>
          </div>
        STORY
      end.join

      <<~MEMBER
        <div class="family-member">
          <h2>#{member.first_name} #{member.last_name}</h2>
          #{birth_info}
          #{death_info}
          #{stories_html}
        </div>
      MEMBER
    end.join

    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Export rodiny #{family.respond_to?(:name) ? family.name : family.id}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          h1, h2 { text-align: center; }
          .family-member { margin-bottom: 40px; border-bottom: 2px solid #000; padding-bottom: 20px; }
          .story { margin-bottom: 20px; border-bottom: 1px solid #ccc; padding-bottom: 10px; }
          .story-title { font-size: 18px; font-weight: bold; }
          .story-content { font-size: 14px; margin-top: 5px; }
        </style>
      </head>
      <body>
        <h1>Export rodiny: #{family.respond_to?(:name) ? family.name : "Rodina #{family.id}"}</h1>
        #{members_html}
      </body>
      </html>
    HTML

    pdf = WickedPdf.new.pdf_from_string(html)

    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    filename = "family_#{family.id}_#{timestamp}.pdf"

    io = StringIO.new(pdf)
    family.export_pdf.attach(
      io: io,
      filename: filename,
      content_type: 'application/pdf'
    )
  end
end
