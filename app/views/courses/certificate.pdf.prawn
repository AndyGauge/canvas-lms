prawn_document(page_layout: :landscape, background: Rails.root.join('lib/on_guard/image/blank_certificate.png')) do |pdf|
  pdf.font_families.update("Great Vibes" => {
      :normal => Rails.root.join('lib/on_guard/font/GreatVibes.ttf')
  })
  pdf.font('Great Vibes')
  pdf.move_down 100
  pdf.text @current_user.name, align: :center, size: 32
  pdf.move_down 170
  pdf.text @completion.completed_at.strftime("%B %d, %Y"), align: :center, size: 32
end
