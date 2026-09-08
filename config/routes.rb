require 'sidekiq/web'

Rails.application.routes.draw do
  # Authentication
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # Memes
  resources :p2w, only: [:index, :show]
  resources :endless, only: [:index]
  resources :random, only: [:index]
  get 'fish', to: redirect('minions/396')
  get 'minions/dark_helmet'
  get 'mounts/pickorpokkur'
  get 'orchestrions/fool', to: redirect('images/fool.png')
  get 'parasols', to: redirect('images/parasols.png')
  get 'peregrin', to: redirect('images/peregrin.png')

  post 'locale/set', to: 'locale#update'

  post 'shared/filter', to: 'shared#filter'

  get 'database/:type/:id/link', to: 'databases#link', as: :database_link

  get 'latest', to: redirect('search')

  resource :import, only: [] do
    collection do
      get :index
      get :export
      post :verify
      post :submit
    end
  end

  resources :mounts, only: [:index, :show]

  resources :minions, only: [:index, :show] do
    get :verminion, on: :collection
  end

  resources :orchestrions, only: [] do
    get :select, on: :collection
  end

  resources :spells, only: [] do
    get :battle, on: :collection
  end

  %i(orchestrions emotes bardings hairstyles armoires outfits spells beasts fashions facewear frames
  field_records survey_records occult_records).each do |resource|
    resources resource, only: [:index, :show] do
      member do
        post :add
        post :remove
      end
    end
  end

  %i(mounts minions hairstyles emotes orchestrions frames spells beasts bardings fashions facewear
  field_records survey_records).each do |resource|
    resources resource, only: [] do
      get :tooltip
    end
  end

  # Backwards compatibility for old field records URLs
  get 'records', to: redirect('field_records')
  get 'records/:id', to: redirect('field_records/%{id}')

  resources :leves, only: [] do
    collection do
      get :battlecraft
      get :tradecraft
      get :fieldcraft
    end

    member do
      post :add
      post :remove
    end
  end

  scope :triad, module: :triad do
    resources :cards, only: [:index, :show] do
      get :tooltip

      member do
        post :add
        post :remove
      end

      collection do
        get :select
        post :set
      end
    end

    get 'cards/no/:id', to: 'cards#no'
    get 'cards/ex/:id', to: 'cards#ex'

    resources :npcs, only: [:index, :show] do
      member do
        post 'add'
        post 'remove'
      end

      post 'defeated/update', on: :collection, to: 'npcs#update_defeated', as: :update_defeated
    end

    resources :decks do
      get 'mine', as: :my, on: :collection
      post 'upvote'
      post 'downvote'
    end

    resources :packs, only: [:index]
  end

  namespace :relics, as: :relic do
    get :weapons
    get :ultimate
    get :armor
    get :tools
    get :garo
  end

  resources :relics, as: :relic, only: [] do
    member do
      post :add
      post :remove
    end
  end

  resources :search, only: [:index]

  resources :tools, only: [] do
    collection do
      get :gemstones
      get :market_board
      get :materiel
      get :treasure
    end
  end

  # Backwards compatibility for old relics URLs
  get 'relics', to: redirect('relics/weapons')
  get 'relics/gear', to: redirect('relics/armor')
  get 'relics/weapons/manual', to: redirect('relics/weapons')

  resources :tomestones, only: [:index, :show]

  get 'yokai', to: 'yokai#index'

  get 'achievements/types', to: redirect('404')
  get 'achievements/types/:id', to: 'achievements#type', as: :achievement_type
  get 'achievements/items', to: 'achievements#items', as: :achievement_items
  get 'achievements/search', to: 'achievements#search', as: :achievement_search
  resources :achievements, only: [:index, :show]

  resources :characters, only: [:show, :destroy] do
    member do
      get 'stats/recent', to: 'characters#stats_recent', as: :stats_recent
      get 'stats/rarity', to: 'characters#stats_rarity', as: :stats_rarity
      get :verify
      post :view
      post :select
      post :peek
      post :validate
    end

    collection do
      get :search
      get :profile
      get 'search/lodestone', to: 'characters#search_lodestone'
      post 'search/lodestone_id', to: 'characters#search_lodestone_id', as: :search_lodestone_id
    end
  end

  resources :free_companies, only: [:show], path: :fc do
    get :collections
    post :refresh, on: :member

    # Deprecated
    get :mounts
    get :spells
  end

  resources :groups do
    get :collections

    member do
      get :manage
      post :refresh
      post :character_search
      post 'add/:character_id', action: :add_character, as: :add_character
      post 'remove/:character_id', action: :remove_character, as: :remove_character
    end

    # Deprecated
    get :mounts
    get :spells
  end

  resources :titles, only: :index

  resources :leaderboards, only: :index do
    collection do
      get 'fc/:id', as: :free_company, action: :free_company
      get 'group/:id', as: :group, action: :group
    end
  end

  resources :items, only: :show

  get 'blank', to: 'static#blank'
  get 'commands', to: 'static#commands'
  get 'faq', to: 'static#faq'
  get 'credits', to: 'static#credits'

  get    'settings',           to: 'settings#edit'
  delete 'settings/unlink',    to: 'settings#unlink_identity',  as: :unlink_identity
  patch  'settings/user',      to: 'settings#update_user',      as: :user_settings
  patch  'settings/character', to: 'settings#update_character', as: :character_settings

  get   'settings/user',      to: redirect('settings')
  get   'settings/character', to: redirect('settings')

  post 'character/refresh/(:id)', to: 'characters#refresh', as: :refresh_character

  delete 'character/forget', to: 'characters#forget', as: :forget_character
  delete 'character/unpeek', to: 'characters#unpeek', as: :unpeek_character

  namespace :api do
    resources :characters, only: :show do
      get ':collection/owned', action: :owned, as: :owned
      get ':collection/missing', action: :missing, as: :missing
    end

    resources :users, only: :show do
      get ':collection/owned', action: :owned, as: :owned
      get ':collection/missing', action: :missing, as: :missing
    end

    %i(achievements titles mounts minions orchestrions emotes bardings hairstyles armoires outfits spells
    fashions facewear frames field_records survey_records occult_records relics leves tomestones).each do |resource|
      resources resource, only: [:index, :show]
    end

    # Backwards compatibility for old field records URLs
    get 'records', to: redirect('api/field_records')
    get 'records/:id', to: redirect('api/field_records/%{id}')

    namespace :triad do
      %i(cards decks npcs packs).each do |resource|
        resources resource, only: [:index, :show]
      end
    end
  end

  get 'api/docs', to: redirect('https://documenter.getpostman.com/view/1779678/TzXzDHM1')

  post 'discord/interactions'

  namespace :admin do
    resources :users, :groups, only: :index

    resources :characters, only: :index do
      member do
        post :support
        delete :unverify
      end
    end

    resources :versions, only: [] do
      post :revert
    end

    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  namespace :mod do
    %i(mounts minions orchestrions emotes bardings hairstyles armoires outfits spells beasts fashions facewear
    frames cards field_records survey_records occult_records).each do |resource|
      resources resource, only: [:index, :edit, :update]
    end

    resources :sources, only: :destroy
    get 'dashboard', action: :index
    get 'translate', to: 'translate#index'
  end

  get '404', to: 'static#not_found', as: :not_found
  match "api/*path", via: :all, to: -> (_) { [404, { 'Content-Type' => 'application/json' },
                                              ['{"status": 404, "error": "Not found"}'] ] }
  match "*path", via: :all, to: redirect('404')

  # Quick 404 for missing images
  scope format: true, constraints: { format: 'png' } do
    get "/*missing", to: proc { [404, {}, ['']] }
  end

  root 'static#home'
end
