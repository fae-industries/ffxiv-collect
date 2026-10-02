require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FfxivCollect
  class Application < Rails::Application
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.cache_store = :file_store, 'tmp/cache'

    config.session_store :cookie_store, key: '_ffxiv_collect_session', expire_after: 1.month, same_site: :lax

    # config.active_job.queue_adapter = :sidekiq

    # Allows organization of models into subdirectories without requiring a clunky namespace
    config.autoload_paths += Dir[Rails.root.join('app/models/character')]
    config.autoload_paths += Dir[Rails.root.join('app/models/triad')]
    config.autoload_paths += Dir[Rails.root.join('app/lib/omniauth')]

    config.i18n.available_locales = %i(en de fr ja chs tc)
    config.i18n.default_locale = :en
    # Avoid throwing on invalid locales and just revert to the default
    config.i18n.enforce_available_locales = false

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :options]
        resource '/discord/interactions', headers: :any, methods: [:post]
      end
    end

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
