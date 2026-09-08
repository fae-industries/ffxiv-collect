module CharacterGroup
  extend ActiveSupport::Concern

  included do
    before_action :set_members, only: [:show, :collections]
    before_action :verify_group_membership!, only: [:show, :collections, :refresh]
  end

  def show
    render 'groups/show'
  end

  def collections
    @collection = params[:collection] || 'mounts'
    @owned_ids = owned_ids(@collection.classify)

    @collectables = @collection.classify.constantize
      .where.not(patch: nil)
      .left_joins(sources: :type)
      .with_filters(cookies)
      .ordered
      .distinct

    unless @collection.match(/spell|beast|record/)
      @collectables = @collectables.reverse_order
    end

    if params[:source_type_id].present?
      @collectables = @collectables.where('source_types.id = ?', params[:source_type_id])
    end

    # Exclude collectables owned by everyone in the group if desired
    @collectables = @collectables.where.not(id: @owned_ids.values.reduce(:&)) if params[:owned] == 'missing'

    render 'groups/collections'
  end

  def refresh
    if @group.syncing?
      flash[:alert] = t('alerts.groups.syncing')
    elsif !@group.syncable?
      flash[:alert] = t('alerts.groups.already_refreshed')
    else
      begin
        @group.refresh
        flash[:success] = t('alerts.groups.refreshed')
      rescue ActiveJob::Uniqueness::JobNotUnique
        flash[:alert] = t('alerts.groups.syncing')
      end
    end

    redirect_to polymorphic_path(@group)
  end

  private
  def set_members
    @members = @group.members.visible.order(:name)
  end

  def owned_ids(collection)
    model = "Character#{collection.classify}".constantize
    id_column = "#{collection.downcase.singularize}_id"

    @owned_ids = model.where(character_id: @members).each_with_object(Hash.new { |k, v| k[v] = [] }) do |char, h|
      h[char.character_id] << char[id_column]
    end

    # Trim the list of members to only include those who own at least one collectable
    # @members = @members.reject { |character| @owned_ids[character.id].empty? }
  end
end
