lock '~> 3.19.2'

set :application, 'collect'
set :repo_url,    'https://github.com/fae-industries/ffxiv-collect'
set :branch,      ENV['BRANCH_NAME'] || 'main'
set :deploy_to,   '/var/rails/collect'
set :default_env, { path: '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH' }

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '3.3.5'

namespace :deploy do
  desc 'Create symlinks'
  after :updating, :symlink do
    on roles(:app) do
      # Application credentials
      execute :ln, '-s', shared_path.join('master.key'), release_path.join('config/master.key')

      # Persisted logs
      execute :ln, '-s', shared_path.join("log/#{fetch(:rails_env)}.log"),
        release_path.join("log/#{fetch(:rails_env)}.log")
      execute :ln, '-s', shared_path.join('log/whenever.log'),
        release_path.join('log/whenever.log')

      # Game data
      execute :rmdir, release_path.join('vendor/xiv-data')
      execute :ln, '-s', '/var/rails/xiv-data', release_path.join('vendor/xiv-data')

      # Framer's kit images
      execute :rm, '-rf', release_path.join('public/images/frames')
      execute :ln, '-s', shared_path.join('public/images/frames'), release_path.join('public/images/frames')

      # Triple Triad card images
      execute :rm, '-rf', release_path.join('public/images/cards/large')
      execute :ln, '-s', shared_path.join('public/images/cards/large'), release_path.join('public/images/cards/large')
    end
  end

  desc 'Restart application'
  after :publishing, :restart do
    on roles(:app) do
      execute 'sudo systemctl restart sidekiq-ffxiv-collect-character'
      execute 'sudo systemctl restart sidekiq-ffxiv-collect-free-company'
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end
