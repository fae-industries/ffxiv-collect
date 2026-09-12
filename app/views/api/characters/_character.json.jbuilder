json.(character, :id, :name, :server, :data_center, :portrait, :avatar, :last_parsed)
json.verified character.verified?

json.achievements do
  json.count character.public_achievements? ? character.achievements_count : 0
  json.total Achievement.count
  json.points character.public_achievements? ? character.achievement_points : 0
  json.points_total Achievement.sum(:points)
  json.ranked_points character.public_achievements? ? character.ranked_achievement_points : 0
  json.ranked_points_total Achievement.exclude_time_limited.sum(:points)
  json.ranked_time character.public_achievements? ? character.last_ranked_achievement_time : nil
  json.public character.public_achievements?
  json.ids character.achievement_ids if params[:ids].present?
  json.obtained @times if @times.present?
end

%w(mount minion hairstyle emote orchestrion frame spell beast barding fashion facewear outfit armoire field_record survey_record occult_record leve card npc).each do |collection|
  json.set! collection.pluralize do
    json.count public_collection?(@character, collection.pluralize) ? character.send("#{collection.pluralize}_count") : 0

    collectables = collection.classify.constantize.available
    collectables = collectables.summonable if collection == 'minion'

    json.total collectables.count

    if collection.match?(/mount|minion/)
      json.ranked_count character.send("ranked_#{collection.pluralize}_count")
      json.ranked_total collectables.ranked.count
    end

    json.ids character.send("#{collection}_ids") if params[:ids].present?

    if @character.has_attribute?("public_#{collection.pluralize}")
      json.public @character.send("public_#{collection.pluralize}")
    end
  end
end

json.relics character_relics(character)

json.leves do
  LeveCategory.crafts.each do |craft|
    json.set! craft do
      leves = Leve.available.joins(:category).where('leve_categories.craft_en = ?', craft)
      owned_ids = @character.leve_ids

      json.count leves.where(id: owned_ids).count
      json.total leves.count
    end
  end
end

json.rankings character.rankings
