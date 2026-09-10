namespace :cache do
  desc 'Cache collectable ownership'
  task ownership: :environment do
    achievement_characters = Character.visible.with_public_achievements
    mount_minion_characters = Character.visible
    manual_collection_characters = Character.visible.verified

    [
      Orchestrion, Emote, Barding, Hairstyle, Armoire, Outfit, Spell, Beast, Relic, Fashion, Facewear,
      FieldRecord, SurveyRecord, OccultRecord, Frame, Card
    ].each do |model|
      cache_ownership(model, manual_collection_characters)
    end

    [Mount, Minion].each do |model|
      cache_ownership(model, mount_minion_characters)
    end

    cache_ownership(Achievement, achievement_characters)

    puts
  end

  def cache_ownership(model, characters)
    log("Caching #{model.name.titleize.pluralize}")
    key = model.name.underscore.pluralize
    relation = "Character#{model}".constantize
    current = Redis.current.hgetall("#{key}-count")
    total = characters.where("#{key}_count > 0").size

    log('Setting percentages')
    ownership = relation.where(character: characters).group("#{key.singularize}_id").count
      .each_with_object({}) do |(id, owners), h|
        percentage = ('%.1f' % ((owners / total.to_f) * 100)).sub('0.0', '0')
        h[id] = { count: owners, percentage: "#{percentage}%" }
      end

    return unless ownership.present?

    log('Collecting updated models')
    updated = ownership.filter_map do |id, data|
      id unless data[:count].to_s == current[id.to_s]
    end

    # Touch collectables with updated ownership to expire cached data
    log('Touching models')
    model.where(id: updated).update_all(updated_at: Time.now)

    Redis.current.hmset(key, ownership_to_set(ownership, :percentage))
    Redis.current.hmset("#{key}-count", ownership_to_set(ownership, :count))
  end
end

private
def ownership_to_set(ownership, key)
  ownership.map { |id, data| [id, data[key]] }.flatten
end
