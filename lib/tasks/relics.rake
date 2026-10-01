namespace :relics do
  namespace :all do
    desc 'Create all relics'
    task create: :environment do
      Rake::Task['relics:weapons:create'].invoke
      Rake::Task['relics:ultimate:create'].invoke
      Rake::Task['relics:armor:create'].invoke
      Rake::Task['relics:tools:create'].invoke
      Rake::Task['relics:garo:create'].invoke
    end
  end

  def create_relics(type, ids, achievement_ids = [])
    ids = ids.to_a

    Item.where(id: ids).sort_by { |item| ids.index(item.id) }.each_with_index do |item, i|
      data = { id: item.id.to_s, order: (i + 1).to_s, type_id: type.id.to_s, achievement_id: achievement_ids[i]&.to_s }
        .merge(item.slice(*Item.locale_columns(:name), :image_url))

      if existing = Relic.find_by(id: data[:id])
        existing.update!(data) if updated?(existing, data)
      else
        Relic.create!(data)
      end
    end
  end
end
