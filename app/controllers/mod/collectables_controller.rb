class Mod::CollectablesController < ModController
  before_action :set_model
  before_action :set_collectable, only: [:edit, :update]
  before_action :set_types, only: [:edit, :update]
  before_action :set_changes, only: [:edit, :update]

  def index
    @q = @model.all.ransack(params[:q])
    @missing_source = params[:missing_source]
    @missing_patch = params[:missing_patch]

    @collectables = @q.result.ordered.paginate(page: params[:page])
    @collectables = @collectables.summonable if @model == Minion
    @collectables = @collectables.includes(sources: [:type, :related]) unless @skip_sources

    if @missing_source
      if @model == SurveyRecord
        @collectables = @collectables.where("solution_en" => nil)
      else
        @collectables = @collectables.left_joins(:sources).group("#{controller_name}.id")
          .having('count(sources.id) = 0')
      end
    end

    if @missing_patch
      @collectables = @collectables.where(patch: nil)
    end
  end

  def edit
    @title = "Edit #{@model.to_s.titleize}#{ " (#{I18n.locale.to_s.upcase})" unless I18n.locale == :en}"
    build_sources
  end

  def update
    update_params = collectable_params
    update_params[:sources_attributes]&.reject! { |_, source| source[:type_id].blank? }

    if @collectable.update(update_params)
      flash[:success] = t('mod.collectable_update_success', collectable: @model.model_name.human.downcase)
      redirect_to polymorphic_url([:mod, @collectable], action: :edit)
    else
      flash[:error] = t('mod.collectable_update_error', collectable: @model.model_name.human.downcase)
      build_sources
      render :edit
    end
  end

  private
  def set_model
    @model = controller_name.singularize.classify.constantize
  end

  def set_collectable
    @collectable = @model.find(params[:id])
  end

  def set_types
    @types = SourceType.all.order("name_#{I18n.locale}")
  end

  def set_changes
    @changes = PaperTrail::Version.where(collectable_type: @model.to_s, collectable_id: @collectable.id)
      .or(PaperTrail::Version.where(item_type: @model.to_s, item_id: @collectable.id))
      .includes(:user).order(id: :desc)
  end

  def skip_sources
    @skip_sources = true
  end

  def build_sources
    return if @skip_sources

    2.times { @collectable.sources.build }
    @order_options = [nil, *(1..@collectable.sources.size).to_a]
  end

  def collectable_params
    params.require(@model.name.underscore)
      .permit(:name_en, :name_de, :name_fr, :name_ja, :name_tc, :patch, :gender,
              :solution_en, :solution_de, :solution_fr, :solution_ja, :solution_tc,
              sources_attributes: [
                :id, :type_id, :collectable_id, :collectable_type, :limited, :premium,
                :order, :text_en, :text_de, :text_fr, :text_ja, :text_tc
              ])
  end
end
