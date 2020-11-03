class EcsProduct < ApplicationRecord
  has_many :ecs_fitments, dependent: :destroy
  has_one :ecs_taxon, dependent: :destroy

  def add_ecs_taxons(taxon, sub_taxon)
    if ecs_taxon.nil?
      create_ecs_taxon(taxon: taxon, sub_taxon: sub_taxon)
    else
      ecs_taxon.update(taxon: taxon, sub_taxon: sub_taxon)
    end
    # puts 'Taxon added.'
  end

  def add_ecs_fitments doc
    rows = doc.xpath("//table[@class='appTable']").css('tr')
    rows.each_with_index do |row, index|
      next if index.zero?

      make = row.children[1].children.text
      modal = row.children[3].children.text
      submodal = row.children[5].children.text
      engine = row.children[7].children.text
      ecs_fitments.find_or_create_by(make: make, model: modal, sub_model: submodal, engine: engine)
    end
    # puts 'Fitments added.'
  end
end
