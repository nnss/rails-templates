=begin
  Template Name: Based on Kickstart application template - Tailwind CSS
  Author: Matias nnss Palomec
  Author URI: https://github.com/nnss/rails-templates
  Instructions: $ rails new myapp -d <postgresql, mysql, sqlite> -m btemplate.rb

examples over https://github.com/dao42/rails-template/blob/master/composer.rb

=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', '~> 4.7', '>= 4.7.1'
  gem 'friendly_id', '~> 5.3'
  gem 'sidekiq', '~> 6.0', '>= 6.0.1'
  gem 'simple_form'
  gem 'acts-as-taggable-on'
  gem 'cocoon'
  gem 'acts_as_commentable_with_threading'
  gem 'acts_as_votable'
  gem 'pagy'
  gem 'recaptcha', :require => 'recaptcha/rails'

end

def after_bundler_group
  generate 'simple_form:install'
end

def add_users
  # Install Devise
  generate 'devise:install'

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, 'User', 'username', 'name', 'admin:boolean'

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob('db/migrate/*').max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ':admin, default: false'
  end
end

def add_foreman
  file "Procfile", <<-CODE
web: rails server
sidekiq: sidekiq
webpack: bin/webpack-dev-server
CODE
end


# Main setup
source_paths

add_gems

after_bundle do
  add_users
  remove_app_css
  add_sidekiq
  add_foreman
  copy_templates
  add_tailwind
  add_friendly_id

  # Migrate
  rails_command 'acts_as_taggable_on_engine:install:migrations'
  rails_command 'db:create'
  rails_command 'db:migrate'

  git :init
  git add: '.'
  git commit: %Q{ -m "Initial commit" }

  say
  say 'app created', :green
  say
end

