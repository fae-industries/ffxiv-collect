class Mod::TranslateController < ModController
  include Typeable

  def index
    @source_types = SourceType.ordered
    @q = Source.ransack(params[:q])
    @sources = @q.result
      .where(Source.current_locale_column(:text) => nil)
      .preload(:collectable)
      .order(id: :desc)
      .paginate(page: params[:page], per_page: 10)
  end
end
