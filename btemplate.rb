=begin
Template Name: Kickstart application template - Tailwind CSS
Author: Andy Leverenz
Author URI: https://web-crunch.com
Instructions: $ rails new myapp -d <postgresql, mysql, sqlite> -m template.rb
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', '~> 4.7', '>= 4.7.1'
  gem 'friendly_id', '~> 5.3'
  gem 'sidekiq', '~> 6.0', '>= 6.0.1'
  gem 'simple_form'
  gem 'awesome_nested_fields'
  gem 'acts-as-taggable-on'
  gem 'cocoon'
  gem 'acts_as_commentable_with_threading'
  gem 'acts_as_votable'
  gem 'nokogiri'
  gem 'recaptcha', :require => 'recaptcha/rails'

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
  copy_file 'Procfile'
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
  rails_command 'db:create'
  rails_command 'db:migrate'

  git :init
  git add: '.'
  git commit: %Q{ -m "Initial commit" }

  say
  say 'Kickoff app successfully created! 👍', :green
  say
  say 'Switch to your app by running:'
  say "$ cd #{app_name}", :yellow
  say
  say 'Then run:'
  say '$ rails server', :green
end

