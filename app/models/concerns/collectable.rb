module Collectable
  extend ActiveSupport::Concern

  included do
    scope :available, -> { where.not(patch: nil) }
    scope :include_sources, -> { includes(:item, sources: [:type, :related] )}
    scope :tradeable, -> { joins(:item).where('items.tradeable IS TRUE') }

    scope :hide_premium, -> (hide) do
      if hide && available_filters.include?(:premium)
        where('sources.premium = FALSE or sources.id IS NULL')
      end
    end

    scope :hide_limited, -> (hide) do
      if hide && available_filters.include?(:limited)
        where('sources.limited = FALSE or sources.id IS NULL')
      end
    end

    scope :hide_ranked_pvp, -> (hide) do
      if hide && available_filters.include?(:ranked_pvp)
        where('(sources.text_en not like "%Season %" and sources.text_en not like "%Commendation Crystals" and sources.text_en <> "Crucible Contender") or sources.id IS NULL')
      end
    end

    scope :hide_armoire_storable, -> (hide) do
      if hide && available_filters.include?(:armoire)
        where(armoireable: false)
      end
    end

    scope :hide_outfit_storable, -> (hide) do
      if hide && available_filters.include?(:outfit)
        where(outfitable: false)
      end
    end

    scope :hide_unknown, -> (hide) do
      if hide && available_filters.include?(:unknown)
        where('sources.id IS NOT NULL')
      end
    end

    scope :filter_gender, -> (option, character) do
      if option.present? && available_filters.include?(:gender)
        if option == 'character'
          # Show collectables usable by the character's gender
          where('gender is null or gender = ?', character.gender) if character&.gender.present?
        elsif option != 'all'
          # Hide collectables for the given gender
          where('gender is null or gender <> ?', option)
        end
      end
    end

    scope :ranked, -> do
      joins(:sources)
        .where('sources.limited = FALSE AND sources.premium = FALSE')
        .distinct
    end

    scope :with_filters, -> (filters, character = nil) do
      left_joins(:sources)
        .hide_premium(filters[:premium] == 'hide')
        .hide_limited(filters[:limited] == 'hide')
        .hide_ranked_pvp(filters[:ranked_pvp] == 'hide')
        .hide_armoire_storable(filters[:armoire] == 'hide')
        .hide_outfit_storable(filters[:outfit] == 'hide')
        .hide_unknown(filters[:unknown] == 'hide')
        .filter_gender(filters[:gender], character)
        .distinct
    end

    belongs_to :item, required: false

    has_many "character_#{name.pluralize.underscore}".to_sym
    has_many :characters, through: "character_#{name.pluralize.underscore}".to_sym
    has_many :sources, as: :collectable, dependent: :delete_all

    delegate :tradeable?, to: :item, allow_nil: true

    accepts_nested_attributes_for :sources

    has_paper_trail

    def expansion
      patch&.first
    end
  end

  class_methods do
    def materiel_container(number)
      case number
      when 3
        tradeable.where('patch < 4.0')
      when 4
        tradeable.where('patch >= 4.0 AND patch < 5.0')
      else
        none
      end
    end

    # Collections are tracked manually by default
    def automatic_collection?
      false
    end
  end
end
