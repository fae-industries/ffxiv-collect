# == Schema Information
#
# Table name: sources
#
#  id               :bigint           not null, primary key
#  collectable_type :string(255)      not null
#  limited          :boolean          default(FALSE)
#  order            :integer
#  premium          :boolean          default(FALSE)
#  related_type     :string(255)
#  text_de          :string(255)
#  text_en          :string(255)
#  text_fr          :string(255)
#  text_ja          :string(255)
#  text_tc          :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  collectable_id   :integer          not null
#  related_id       :integer
#  type_id          :integer          not null
#

class Source < ApplicationRecord
  belongs_to :collectable, polymorphic: true, touch: true
  belongs_to :related, polymorphic: true, required: false
  belongs_to :type, class_name: 'SourceType'

  before_save :assign_relations!, :fill_translations!

  has_paper_trail meta: { collectable_type: :collectable_type, collectable_id: :collectable_id }

  translates :text

  scope :exclude_premium, -> { where(premium: false) }
  scope :exclude_limited, -> { where(limited: false) }
  scope :ordered, -> { order(order: :asc, id: :asc) }

  def self.ransackable_attributes(auth_object = nil)
    super + %w(
      text_en text_de text_fr text_ja text_tc
      premium limited order
      related_id type_id related_type collectable_id collectable_type
    )
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w(collectable related)
  end

  private
  def assign_relations!
    locale = nil

    %w(en de fr ja tc).each do |i18n|
      break locale = i18n if changes.keys.include?("text_#{i18n}")
    end

    return unless locale.present?

    text = self["text_#{locale}"]
    type = SourceType.find(type_id)

    case type.name_en
    when /(Achievement|Quest)/
      if relation = type.name_en.constantize.find_by("name_#{locale}" => text)
        set_text_for_relation!(relation)
        self.related_id = relation.id
        self.related_type = type.name_en

        if self.related_type == 'Achievement' && relation.time_limited?
          self.limited = true
        end
      else
        remove_relation!
      end
    when *ContentType.instance_type_names
      if relation = Instance.find_by("name_#{locale}" => text)
        set_text_for_relation!(relation)
        self.related_id = relation.id
        self.related_type = 'Instance'
      else
        remove_relation!
      end
    when 'Event'
      self.limited = true

      if relation = Quest.find_by("name_#{locale}" => text)
        set_text_for_relation!(relation)
        self.related_id = relation.id
        self.related_type = 'Quest'
      else
        remove_relation!
      end
    when 'NPC'
      if relation = NPC.find_by("name_#{locale}" => text)
        set_text_for_relation!(relation)
        self.related_id = relation.id
        self.related_type = 'NPC'
      else
        remove_relation!
      end
    when 'Premium'
      self.premium = true
    when 'Crafting'
    else
      remove_relation! if persisted?
    end
  end

  def remove_relation!
    self.related_id = nil
    self.related_type = nil
  end

  def set_text_for_relation!(relation)
    %w(en de fr ja tc).each do |locale|
      self["text_#{locale}"] = relation["name_#{locale}"]
    end
  end

  def fill_translations!
    # Skip additional callbacks to avoid endless loops
    Source.skip_callback(:save, :before, :assign_relations!)
    Source.skip_callback(:save, :before, :fill_translations!)

    if text_en_changed?
      # Populate non-English source texts from an existing matching source
      %w(text_de text_fr text_ja text_tc).each do |text|
        next unless self[text].nil?

        existing = Source.where(text_en: self.text_en)
          .where.not(text => nil)
          .first

        self[text] = existing.try(:[], text)
      end
    end

    # Propagate translations to existing sources with the same English text
    unless text_en.nil?
      %w(text_de text_fr text_ja text_tc).each do |text|
        if changes.keys.include?(text)
          Source.where(text_en: text_en).where(text => nil).excluding(self).each do |source|
            source.update!(text => self[text])
          end
        end
      end
    end

    Source.set_callback(:save, :before, :assign_relations!)
    Source.set_callback(:save, :before, :fill_translations!)
  end
end
