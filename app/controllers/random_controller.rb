class RandomController < ApplicationController
  COLLECTIONS = [
    Achievement, Mount, Minion, Orchestrion, Spell, Hairstyle, Emote, Barding, Armoire, Outfit, Fashion,
    Facewear, Frame, Card, NPC, FieldRecord, SurveyRecord
  ].freeze

  def index
    # Try up to 10 times in case a character has every item in a collection
    retries = 10

    while retries > 0
      model = COLLECTIONS.sample

      if !@character.present?
        return redirect_to polymorphic_path(model.find(model.ids.sample))
      end

      character_ids = @character.send("#{model.to_s.underscore}_ids")
      unowned_ids = model.ids - character_ids

      if unowned_ids.length > 0
        return redirect_to polymorphic_path(model.find(unowned_ids.sample))
      end

      retries -= 1
    end

    redirect_to root_path
  end
end
