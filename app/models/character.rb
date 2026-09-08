# == Schema Information
#
# Table name: characters
#
#  id                           :bigint           not null, primary key
#  achievement_points           :integer          default(0)
#  achievements_count           :integer          default(0)
#  armoires_count               :integer          default(0)
#  avatar                       :string(255)      not null
#  banned                       :boolean          default(FALSE)
#  bardings_count               :integer          default(0)
#  beasts_count                 :integer          default(0)
#  cards_count                  :integer          default(0)
#  data_center                  :string(255)
#  emotes_count                 :integer          default(0)
#  facewear_count               :integer          default(0)
#  fashions_count               :integer          default(0)
#  field_records_count          :integer          default(0)
#  frames_count                 :integer          default(0)
#  gender                       :string(255)
#  hairstyles_count             :integer          default(0)
#  last_parsed                  :datetime
#  last_ranked_achievement_time :datetime
#  leves_count                  :integer          default(0)
#  minions_count                :integer          default(0)
#  mounts_count                 :integer          default(0)
#  name                         :string(255)      not null
#  npcs_count                   :integer          default(0)
#  occult_records_count         :integer          default(0)
#  orchestrions_count           :integer          default(0)
#  outfits_count                :integer          default(0)
#  portrait                     :string(255)
#  pricing_data_center          :string(255)
#  public                       :boolean          default(TRUE)
#  public_achievements          :boolean          default(FALSE)
#  public_emotes                :boolean          default(FALSE)
#  public_facewear              :boolean          default(TRUE)
#  public_minions               :boolean          default(TRUE)
#  public_mounts                :boolean          default(TRUE)
#  public_profile               :boolean          default(TRUE)
#  queued_at                    :datetime         default(1970-01-01 00:00:00.000000000 UTC +00:00)
#  ranked_achievement_points    :integer          default(0)
#  ranked_minions_count         :integer          default(0)
#  ranked_mounts_count          :integer          default(0)
#  refreshed_at                 :datetime         default(1970-01-01 00:00:00.000000000 UTC +00:00)
#  relics_count                 :integer          default(0)
#  server                       :string(255)      not null
#  spells_count                 :integer          default(0)
#  supporter                    :boolean          default(FALSE)
#  survey_records_count         :integer          default(0)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  free_company_id              :string(255)
#  verified_user_id             :integer
#

class Character < ApplicationRecord
  after_destroy :clear_user_characters
  belongs_to :verified_user, class_name: 'User', required: false
  belongs_to :free_company, required: false

  has_many :group_memberships
  has_many :groups, through: :group_memberships

  scope :recent,   -> { where('characters.updated_at > ?', Date.current - 3.months) }
  scope :verified, -> { where.not(verified_user: nil) }
  scope :visible,  -> { where(public: true, banned: false) }
  scope :with_public_achievements, -> { where(public_achievements: true) }

  %i(achievements mounts minions orchestrions emotes bardings hairstyles armoires outfits spells beasts relics
  fashions facewear field_records survey_records occult_records frames leves cards npcs).each do |model|
    has_many "character_#{model}".to_sym, dependent: :delete_all
    has_many model, through: "character_#{model}".to_sym
  end

  def sync
    update(queued_at: Time.now)
    CharacterSyncJob.perform_async(id)
  end

  def verify!(user)
    if Lodestone.verified?(id, verification_code(user))
      update!(verified_user_id: user.id)
    end
  end

  def verification_code(user)
    code = Digest::SHA2.hexdigest("#{user.id}-#{self.id}")
    "ffxivcollect:#{code}"
  end

  def verified?
    verified_user_id.present?
  end

  def verified_user?(user)
    user.present? && user.id == verified_user_id
  end

  def private?(user = nil)
    if user.present?
      !self.public && verified_user_id != user.id
    else
      !self.public
    end
  end

  def expire!
    time = Time.at(0)
    update!(last_parsed: time, queued_at: time, refreshed_at: time)
  end

  def stale?
    last_parsed < Time.now - 6.hours
  end

  def refreshable?
    refreshed_at < Time.now - 30.minutes
  end

  def early_user?
    verified? && verified_user.created_at <= '2020-06-20'
  end

  def most_recent(collection, filters: nil, limit: 10)
    if collection == 'titles'
      collectables = achievements.joins(:title).includes(:title).order('character_achievements.created_at desc')
    else
      collectables = send(collection).order("character_#{collection}.created_at desc")
    end

    collectables = collectables.with_filters(filters, self) if filters.present?
    collectables.first(limit).map do |collectable|
      { collectable: collectable }
    end
  end

  def most_rare(collection, filters: nil, limit: 10)
    if collection == 'titles'
      collectables = achievements.joins(:title).includes(:title)
      key = 'achievements'
    else
      collectables = send(collection)
      key = collection
    end

    rarities = {
      count: Redis.current.hgetall("#{key}-count"),
      percentage: Redis.current.hgetall(key)
    }

    sorted_ids = rarities[:count].sort_by { |k, v| v.to_f }.map { |k, v| k.to_i }
    valid_ids = rarities[:count].keys.map(&:to_i) # Exclude new collectables with no rarity values

    collectables = collectables.with_filters(filters, self) if filters.present?
    collectables = collectables.select { |collectable| valid_ids.include?(collectable.id) }
      .sort_by { |collectable| sorted_ids.index(collectable.id) }

    collectables.first(limit).map do |collectable|
      { collectable: collectable,
        count: rarities[:count][collectable.id.to_s],
        percentage: rarities[:percentage][collectable.id.to_s] }
    end
  end

  def rankings
    %i(achievements mounts minions).each_with_object({}) do |category, h|
      h[category] = {
        server: Redis.current.hget("rankings-#{category}-#{server.downcase}", id)&.to_i,
        data_center: Redis.current.hget("rankings-#{category}-#{data_center.downcase}", id)&.to_i,
        global: Redis.current.hget("rankings-#{category}-global", id)&.to_i
      }
    end
  end

  def region
    Rails.application.config_for(:characters).data_centers[data_center.to_sym][:region]
  end

  def fetch!
    Character.fetch(id)
  end

  def set_cards(ids)
    old_ids = self.card_ids

    # Bulk insert the newly added cards
    add_ids = ids - old_ids
    if add_ids.present?
      Character.bulk_insert(self.id, CharacterCard, :card, add_ids)
    end

    # Bulk delete the newly removed cards
    remove_ids = old_ids - ids
    if remove_ids.present?
      CharacterCard.where(character_id: self.id, card_id: remove_ids).delete_all
    end

    # Update the counter cache
    Character.reset_counters(self.id, :cards_count)
  end

  def set_npcs(ids)
    if ids.present?
      Character.bulk_insert(self.id, CharacterNPC, :npc, ids)
    end
  end

  def self.fetch(id)
    character = Character.find_by(id: id)

    begin
      data = Lodestone.character(id)
    rescue Lodestone::HiddenProfileError => e
      character.update!(public: false, public_profile: false, last_parsed: Time.now)
      raise e
    rescue Lodestone::PrivateProfileError => e
      if character.present?
        character.update!(public_profile: false, last_parsed: Time.now)
      end

      raise e
    end

    # Remove character from rankings when collections have been set to private
    data[:ranked_achievement_points] = -1 unless data[:public_achievements]
    data[:ranked_mounts_count] = -1 unless data[:public_mounts]
    data[:ranked_minions_count] = -1 unless data[:public_minions]

    profile_data = data.except(:achievements, :mounts, :minions, :facewear, :emotes)

    if character.present?
      character.update!(profile_data)
    else
      character = Character.create!(profile_data)
    end

    Character.update_collectables!(character, data)
  end

  def self.data_centers
    servers_by_data_center.keys.sort.freeze
  end

  def self.data_centers_by_region
    data_centers = { 'na' => [], 'eu' => [], 'jp' => [], 'oc' => [] }

    Rails.application.config_for(:characters).data_centers
      .each { |k, v| data_centers[v[:region]] << k.to_s }

    data_centers.freeze
  end

  def self.servers
    servers_by_data_center.values.flatten.sort.freeze
  end

  def self.servers_by_data_center
    Rails.application.config_for(:characters).data_centers
      .each_with_object({}) { |(k, v), h| h[k.to_s] = v[:servers] }.freeze
  end

  def self.leaderboards(characters:, metric:, data_center: nil, server: nil, limit: nil, rankings: false)
    q = { data_center_eq: data_center, server_eq: server }.compact
    ranked_characters = characters.where("#{metric} > 0").ransack(q).result

    # Exclude characters with private collections
    case metric
    when /achievement/
      ranked_characters = ranked_characters.where(public_achievements: true)
    when /mount/
      ranked_characters = ranked_characters.where(public_mounts: true)
    when /minion/
      ranked_characters = ranked_characters.where(public_minions: true)
    when /facewear/
      ranked_characters = ranked_characters.where(public_facewear: true)
    end

    # Order the results based on the metric
    if metric.match?('achievement')
      ranked_characters = ranked_characters
        .order(metric => :desc, last_ranked_achievement_time: :asc, name: :asc)
        .limit(limit)
    else
      ranked_characters = ranked_characters
        .order(metric => :desc, name: :asc)
        .limit(limit)
    end

    # Only select necessary columns when caching rankings
    if rankings
      if metric.match?('achievement')
        ranked_characters = ranked_characters.select(:id, metric, :last_ranked_achievement_time)
      else
        ranked_characters = ranked_characters.select(:id, metric)
      end
    end

    return [] if ranked_characters.empty?

    current_score = ranked_characters[0][metric]
    current_date = ranked_characters[0].last_ranked_achievement_time if metric.match?('achievement')
    rank = 1

    ranked_characters.map.with_index(1) do |character, i|
      score = character[metric]

      if metric.match?('achievement')
        date = character.last_ranked_achievement_time

        if score != current_score || date != current_date
          rank = i
          current_score = score
          current_date = date
        end
      else
        if score != current_score
          rank = i
          current_score = score
        end
      end

      { rank: rank, character: character, score: score, date: date }
    end
  end

  def self.available_filters
    %i(gender premium limited ranked_pvp armoire unknown)
  end

  def self.ransackable_attributes(auth_object = nil)
    attributes = super + %w(server data_center)

    if auth_object == :admin
      attributes += %w(verified public supporter)
    end

    attributes
  end

  def self.ransackable_associations(auth_object = nil)
    if auth_object == :admin
      super + %w(verified_user)
    else
      super
    end
  end

  private
  def self.update_collectables!(character, data)
    # Achievements
    character_achievement_ids = character.achievement_ids
    new_achievements = data[:achievements].reject { |achievement| character_achievement_ids.include?(achievement[:id]) }

    if new_achievements.present?
      Character.bulk_insert_with_dates(character.id, CharacterAchievement, :achievement, new_achievements)
      character.update(achievement_points: character.achievements.sum(:points))
    end

    is_now_public = character.public_achievements && character.ranked_achievement_points == -1

    # Don't update rankings if the character has not earned any new achievements,
    # unless the character has toggled their Lodestone privacy settings.
    if data[:achievements].present? || is_now_public
      ranked_time = CharacterAchievement.where(character_id: character.id)
        .joins(:achievement).merge(Achievement.exclude_time_limited)
        .order(:created_at).last&.created_at

      character.update(ranked_achievement_points: character.achievements.exclude_time_limited.sum(:points),
                       last_ranked_achievement_time: ranked_time)
    end

    # Relics - Update based on ALL of a character's relic achievements so we can add them retroactively
    new_relics = Relic.where.not(id: character.relic_ids)
      .where(achievement_id: character_achievement_ids)
      .map do |relic|
        { id: relic.id, achievement_id: relic.achievement_id }
      end

    if new_relics.present?
      # Collect the dates for character achievements matching the new relics
      achievement_dates = character.character_achievements
        .where(achievement_id: new_relics.pluck(:achievement_id))
        .pluck(:achievement_id, :created_at)
        .to_h

      # Add the dates to the relic data
      new_relics.each do |relic|
        relic[:date] = achievement_dates[relic[:achievement_id]].to_formatted_s(:db)
      end

      Character.bulk_insert_with_dates(character.id, CharacterRelic, :relic, new_relics)
    end

    # Mounts
    new_mounts = data[:mounts] - character.mount_ids

    if new_mounts.present?
      Character.bulk_insert(character.id, CharacterMount, :mount, new_mounts)
    end

    # Re-check the ranked count since sources can change, unless the collection is private
    if character.public_mounts?
      character.update(ranked_mounts_count: character.mounts.ranked.count)
    end

    # Minions
    new_minions = data[:minions] - character.minion_ids

    if new_minions.present?
      Character.bulk_insert(character.id, CharacterMinion, :minion, new_minions)
    end

    # Re-check the ranked count since sources can change, unless the collection is private
    if character.public_minions?
      character.update(ranked_minions_count: character.minions.ranked.count)
    end

    # Facewear
    new_facewear = data[:facewear] - character.facewear_ids

    if new_facewear.present?
      Character.bulk_insert(character.id, CharacterFacewear, :facewear, new_facewear)
    end

    # Emotes
    new_emotes = data[:emotes] - character.emote_ids

    if new_emotes.present?
      Character.bulk_insert(character.id, CharacterEmote, :emote, new_emotes)
    end

    Character.find(character.id)
  end

  def self.bulk_insert(character_id, model, model_name, ids)
    id_field = "#{model_name}_id"

    model.insert_all(ids.map { |id| { character_id: character_id, id_field => id }})

    Character.reset_counters(character_id, "#{model_name.to_s.pluralize}_count")
  end

  def self.bulk_insert_with_dates(character_id, model, model_name, collectables)
    return unless collectables.present?

    id_field = "#{model_name}_id"

    data = collectables.map do |collectable|
      {
        character_id: character_id,
        id_field => collectable[:id],
        created_at: collectable[:date],
        updated_at: collectable[:date]
      }
    end

    model.insert_all(data)

    Character.reset_counters(character_id, "#{model_name.to_s.pluralize}_count")
  end

  def clear_user_characters
    User.where(character_id: self.id).update_all(character_id: nil)
  end
end
