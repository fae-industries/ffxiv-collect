class ImportController < ApplicationController
  before_action :verify_user!
  before_action :set_keys
  before_action :set_character_data, only: [:export, :verify]

  def index
  end

  def export
    filename = ['ffxiv_collect_export', @character.name, @character.server, Time.now.to_formatted_s(:number)]
      .join('_')
      .gsub(' ', '_')
      .downcase
      .concat('.json')

    respond_to do |format|
      format.json { send_data @character_data.to_json, filename: filename }
    end
  end

  def verify
    begin
      @data = parse_data

      raise JSON::ParserError if @data.empty?

      @current_counts = {}
      @new_counts = {}

      @data.each do |collection, ids|
        @current_counts[collection] = @character_data[collection].size
        @new_counts[collection] = ids.count
      end
    rescue JSON::ParserError
      flash.now[:error] = t('import.invalid_json')
      render :index
    rescue StandardError => e
      log_backtrace(e)
      flash.now[:error] = t('import.error')
      render :index
    end
  end

  def submit
    begin
      @data = parse_data

      @data.each do |collection, ids|
        model = collection.classify.constantize
        ids = model.pluck(:id) & ids

        table = "Character#{collection.classify}".constantize
        id_field = "#{collection.singularize}_id"
        count_field = "#{collection}_count"

        table.transaction do
          table.where(character_id: @character.id).where.not(id_field => ids).delete_all

          if ids.size > 0
            table.insert_all(ids.map { |id| { character_id: @character.id, id_field => id }})
          end

          Character.reset_counters(@character.id, count_field)
        end
      end

      flash[:success] = t('import.success')
      redirect_to import_path
    rescue JSON::ParserError
      flash.now[:error] = t('import.invalid_json')
      render :index
    rescue StandardError => e
      log_backtrace(e)
      flash.now[:error] = t('import.error')
      render :index
    end
  end

  private
  def set_character_data
    @character_data = @keys.each_with_object({}) do |key, h|
      h[key] = @character.public_send("#{key.singularize}_ids")
    end
  end

  def set_keys
    @keys = %w(armoires bardings beasts cards fashions field_records frames hairstyles leves npcs occult_records orchestrions outfits relics spells survey_records)
  end

  def parse_data
    raise ArgumentError.new('Payload too large') if params[:data].bytesize > 1.megabyte

    # Sanitize collection keys
    @data = JSON.parse(params[:data]).select { |k, _| @keys.include?(k)}

    # Sanitize IDs
    @data.each do |collection, ids|
      model = collection.classify.constantize
      @data[collection] = model.pluck(:id) & ids
    end
  end
end
