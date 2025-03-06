class ExportFamilyTreeJob < ApplicationJob
  queue_as :default

  LEVELS = 6

  def perform(family_member_id, language)
    @target = FamilyMember.find(family_member_id)

    levels = build_tree_levels(@target, LEVELS)
    svg = generate_svg(levels)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Rodokmen - #{@target.first_name} #{@target.last_name}</title>
        <style>
          @page { margin: 40px; }
          html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
          }
          .container {
            display: flex;
            justify-content: center;
            align-items: center;
            width: #{@canvas_width}px;
            height: #{@canvas_height}px;
            margin: auto;
            position: relative;
          }
          svg {
            max-width: 100%;
            max-height: 100%;
          }
        </style>
      </head>
      <body>
        <div class="container">
          #{svg}
        </div>
      </body>
      </html>
    HTML

    pdf = WickedPdf.new.pdf_from_string(
      html,
      page_size: 'A0',
      orientation: 'Landscape',
      margin: { top: 40, bottom: 40, left: 40, right: 40 }
    )

    if language == "cs"
      timestamp = Time.current.strftime('%Y%m%d%H%M%S')
      filename  = "rodokmen_clena_rodiny_#{timestamp}.pdf"
      io = StringIO.new(pdf)
      @target.exports.attach(
        io: io,
        filename: filename,
        content_type: 'application/pdf'
      )
      ExportMailer.export_family_tree_ready_cs_email(@target).deliver_later
    else
      timestamp = Time.current.strftime('%Y%m%d%H%M%S')
      filename  = "family_tree_of_family_member_#{timestamp}.pdf"
      io = StringIO.new(pdf)
      @target.exports.attach(
        io: io,
        filename: filename,
        content_type: 'application/pdf'
      )
      ExportMailer.export_family_tree_ready_en_email(@target).deliver_later
    end
  end

  private

  def build_tree_levels(member, levels)
    tree = []
    current_level = [member]
    levels.times do
      tree << current_level
      next_level = []
      current_level.each do |m|
        if m
          next_level << m.mother
          next_level << m.father
        else
          next_level << nil
          next_level << nil
        end
      end
      current_level = next_level
    end
    tree
  end

  def truncate_line(text, max_line = 20)
    text.length > max_line ? text[0, max_line - 1] + "." : text
  end

  def format_multiline(text, max_line = 20)
    return text if text.length <= max_line

    words = text.split
    if words.size >= 2
      line1 = truncate_line(words.first, max_line)
      line2 = truncate_line(words[1..-1].join(" "), max_line)
      "#{line1}\n#{line2}"
    else
      truncate_line(text, max_line)
    end
  end

  def format_full_name(member)
    return "" unless member
    first = member.first_name.to_s.strip
    last  = member.last_name.to_s.strip
    full = "#{first} #{last}"
    full.length <= 20 ? full : format_multiline(full, 20)
  end

  def format_date(date)
    date.present? ? date.strftime('%d.%m.%Y') : ""
  end

  def node_label(member)
    name = format_full_name(member)
    dob = member&.date_of_birth ? "* #{format_date(member.date_of_birth)}" : ""
    dod = (member && member.deceased && member.date_of_death) ? "✝ #{format_date(member.date_of_death)}" : ""
    label = name
    label += "\n#{dob}" unless dob.empty?
    label += "\n#{dod}" unless dod.empty?
    label
  end

  def generate_svg(levels)
    require 'graphviz'
    g = GraphViz.new(:G, type: :digraph)
    g.graph[:layout] = 'twopi'
    g.graph[:root] = "n0_0"
    g.graph[:overlap] = false
    g.graph[:size] = "46,33!"
    g.graph[:ratio] = "fill"

    nodes = {}
    levels.each_with_index do |level, i|
      level.each_with_index do |member, j|
        node_id = "n#{i}_#{j}"
        label = member ? node_label(member) : ""
        node_opts = {
          label: label,
          shape: 'box',
          fontsize: 22,
          fixedsize: true,
          width: 4,
          height: 2
        }
        if member && member.id == @target.id
          node_opts[:fillcolor] = "lightblue"
          node_opts[:style] = "filled"
        end
        nodes[[i, j]] = g.add_nodes(node_id, node_opts)
      end
    end

    levels.each_with_index do |level, i|
      next if i == 0
      level.each_with_index do |member, j|
        parent_index = j / 2
        edge_label = (j.even? ? "matka" : "otec")
        g.add_edges(nodes[[i - 1, parent_index]], nodes[[i, j]], label: edge_label, fontsize: 14, penwidth: 3)
      end
    end

    g.node[:fontname] = 'Arial'
    g.edge[:fontsize] = 12

    svg_string = g.output(svg: String)
    svg_string.force_encoding('UTF-8')

    @canvas_width = 4950
    @canvas_height = 3535

    svg_string
  end
end
