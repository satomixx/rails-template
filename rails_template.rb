# coding: utf-8
dir = File.dirname(__FILE__)

return unless yes?('Use Template?')

if yes?('use grape?')
  gem 'grape'
end

use_heroku = if yes?('use heroku')
               gem 'rails_12factor', group: :production
               true
             else
               false
             end

if yes?('use db?')
  # PG/MySQL Log Formatter
  gem 'rails-flog'
  if yes('use mysql?')
    gem 'mysql2'
  end
  if yes('use pg?')
    gem 'pg'
    gem 'rails_12factor'
  end
end

use_devise = if yes?('use devise?')
              gem 'devise'
              gem 'devise_zxcvbn'
              gem 'devise-i18n'
              gem 'omniauth'
              gem 'omniauth-twitter'
              gem 'omniauth-facebook'
              gem 'omniauth-google'
              devise_model = ask 'Please input devise model name. ex) User, Admin: '
              true
             else
               false
             end

if yes?('use active_admin?')
  # admin
  gem 'activeadmin', github: 'gregbell/active_admin'
  gem 'active_admin_importable'
end

use_cancancan = if yes?('use cancancan')
                  gem 'cancancan'
                  true
                else
                  false
                end

if yes?('use slim?')
  gem 'html2slim'  
  gem 'slim-rails', github: 'slim-template/slim-rails'
end

if yes?('use simple_form?')
  gem 'simple_form', github: 'plataformatec/simple_form', branch: 'master'
end

use_bootstrap = if yes?('use bootstrap?')
                  uncomment_lines 'Gemfile', "gem 'therubyracer'"
                  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
                  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git' # rails generate bootstrap:install less
                  gem "font-awesome-rails"
                  true
                else
                  false
                end

use_unicorn = if yes?('Use unicorn?')
                uncomment_lines 'Gemfile', "gem 'unicorn'"
                true
              else
                false
              end

use_puma = if yes?('Use puma?')
             gem 'puma'
             true
           else
             false
           end


# Assets log cleaner
gem 'quiet_assets'


if yes?('use carrierwave?')
  # Image File Uploader
  gem 'carrierwave'
  gem 'rmagick', :require => false
  gem 'fog', '~> 1.3.1'
end

# for AWS upload
gem "aws-sdk"

# Pagenation
gem 'kaminari'

gem 'ransack'
gem 'active_decorator'

# check performance
gem 'newrelic_rpm'

# Seed Management
gem 'seed-fu', github: 'mbleigh/seed-fu'

# constant value, settings
gem 'rails_config'

# Use ActiveModel has_secure_password
gem 'bcrypt'

# SEO
gem 'meta-tags', :require => 'meta_tags'
gem 'sitemap_generator'

if yes('use whenever?')
  gem 'whenever', :require => false
end

gem "global"

# Hash extensions
gem 'hashie'

# Progress Bar
#gem 'nprogress-rails'

# presenter layer
#gem 'draper'

gem_group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Airbrake
  #gem 'airbrake'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # make ER map
  gem "rails-erd"

  # good to read error screen
  gem 'better_errors'
  gem 'binding_of_caller'

  # Rack Profiler
  # gem 'rack-mini-profiler'

  # check unuseful sql
  gem 'bullet'

  # tells me rails best practice
  gem 'rails_best_practices'

  gem "annotate"
  gen 'letter_opener'
  gem 'rubocop'
  gem 'timecop'

  gem "guard"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "guard-shell"

  # Pry
  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'awesome_print' # remove to get mongo error away
  # nice show of sql result
  gem 'hirb'
  gem 'hirb-unicode'

  # RSpec
  gem 'rspec-rails'
  gem 'annotate'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_rewinder'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'poltergeist'
  gem 'timecop'
  gem 'launchy'
  gem 'faker-precure'
  gem "rspec-parameterized"
  gem "rspec-power_assert"
  gem "timecop"
  gem "webmock"
end

if yes('use rails assets?')
  add_source('https://rails-assets.org')
  gem 'rails-assets-bootstrap' if yes('use bootstrap?')
end

run 'bundle install --path vendor/bundle'
generate 'kaminari:config'
generate 'rspec:install'
remove_dir 'test'

if use_bootstrap
  generate 'bootstrap:install', 'less'
  generate 'simple_form:install', '--bootstrap'
  if yes?("Use responsive layout?")
    generate 'bootstrap:layout', 'application fluid'
  else
    generate 'bootstrap:layout', 'application fixed'
    append_to_file 'app/assets/stylesheets/application.css' do
      "body { padding-top:60px }"
    end
  end
  remove_file 'app/views/layouts/application.html.erb'
else
  generate 'simple_form:install'
end

application <<-GENERATORS
config.active_record.default_timezone = :local
config.time_zone = 'Tokyo'
config.i18n.default_locale = :ja
config.generators do |g|
  g.orm :active_record
  #g.template_engine :slim
  g.helper false
  g.assets false
  g.test_framework :rspec, fixture: true, fixture_replacement: :factory_girl
  g.controller_specs false
  g.request_specs false
  g.view_specs false
  g.helper_specs false
  g.routing_specs false
end
config.autoload_paths += %W(#{config.root}/lib)
GENERATORS

# Environment setting
# ----------------------------------------------------------------
comment_lines 'config/environments/production.rb', "config.serve_static_assets = false"
environment 'config.serve_static_assets = true', env: 'production'
environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'

# RSpec setting
# ----------------------------------------------------------------
remove_file 'spec'
directory File.expand_path('spec', dir), 'spec', recursive: true

if use_devise
  uncomment_lines 'spec/spec_helper.rb', 'include Warden::Test::Helpers'
  uncomment_lines 'spec/spec_helper.rb', 'config.include Devise::TestHelpers, type: :controller'
  uncomment_lines 'spec/spec_helper.rb', 'config.include Devise::TestHelpers, type: :view'
  uncomment_lines 'spec/spec_helper.rb', 'Warden.test_mode!'
  uncomment_lines 'spec/spec_helper.rb', 'Warden.test_reset!'
  generate 'devise:install'
end

if use_cancan
  generate 'cancan:ability'
end

append_to_file '.rspec' do
  "--format documentation\n--format ParallelTests::RSpec::FailuresLogger --out tmp/failing_specs.log"
end

# Unicorn setting
# ----------------------------------------------------------------
if use_unicorn
  copy_file File.expand_path('config/unicorn.rb', dir), 'config/unicorn.rb'
  create_file 'Procfile' do
    body = <<EOS
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
EOS
  end
else
  create_file 'Procfile' do
    body = <<EOS
web: bundle exec rails server -p $PORT
EOS
  end
end

create_file '.foreman' do
  body = <<EOS
port: 3000
EOS
end

# .gitignore settings
# ----------------------------------------------------------------
remove_file '.gitignore'
create_file '.gitignore' do
  body = <<EOS
/.bundle
/db/*.sqlite3
/log/*.log
/tmp
.DS_Store
/public/assets*
/config/database.yml
newrelic.yml
.foreman
.env
doc/
*.swp
*~
.project
.idea
.secret
/*.iml
EOS
end

# Root path settings
# ----------------------------------------------------------------
generate 'controller', 'home index'
route "root to: 'home#index'"



# Create directories
# ----------------------------------------------------------------
empty_directory 'app/decorators'
create_file 'app/decorators/.gitkeep'

# Database settings
# ----------------------------------------------------------------
case gem_for_database
  when 'pg', 'mysql2'
    run "sed -i -e \"s/#{app_name}_test/#{app_name}_test<%= ENV[\\'TEST_ENV_NUMBER\\']%>/g\" config/database.yml"
  when 'sqlite3'
    run "sed -i -e \"s/db\\/test.sqlite3/db\\/test<%= ENV[\\'TEST_ENV_NUMBER\\']%>.sqlite3/g\" config/database.yml"
  else
end

run "cp config/database.yml config/database.yml.sample"

case gem_for_database
  when 'pg'
    run "createuser -h localhost -d #{app_name}"
  else
end

rake 'db:drop'
rake 'db:create'
rake 'db:migrate'
rake 'parallel:create'
rake 'parallel:prepare'

# git
# ----------------------------------------------------------------
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# Bitbucket
# ----------------------------------------------------------------
use_bitbucket = if yes?('Push Bitbucket?')
                  git_uri = `git config remote.origin.url`.strip
                  if git_uri.size == 0
                    username = ask "What is your Bitbucket username?"
                    password = ask "What is your Bitbucket password?"
                    run "curl -k -X POST --user #{username}:#{password} 'https://api.bitbucket.org/1.0/repositories' -d 'name=#{app_name}&is_private=true'"
                    git remote: "add origin git@bitbucket.org:#{username}/#{app_name}.git"
                    git push: 'origin master'
                  else
                    say "Repository already exists:"
                    say "#{git_uri}"
                  end
                  true
                else
                  false
                end

if use_heroku
  if yes?('Deploy heroku staging?')
    run 'heroku create --remote staging'
    git push: 'staging master'
  end
end

if use_devise
  environment "config.action_mailer.default_url_options = { host: 'localhost:3000' }", env: 'development'
  environment "config.action_mailer.default_url_options = { host: 'localhost:3000' }", env: 'test'
  generate "devise #{devise_model}"
  generate 'devise:views'
  git add: "."
  git commit: %Q{ -m 'Add devise model and views.' }
  if use_bitbucket
    git push: 'origin master'
  end
  say "!!! Please set up #{devise_model} migration file and rake db:migrate !!!"
end
exit

##get 'https://gist.github.com/chiastolite/7197619/raw/application.html.slim', './app/views/layouts/application.html.slim'
