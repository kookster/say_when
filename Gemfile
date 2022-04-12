source "http://rubygems.org"

# Specify your gem's dependencies in say_when.gemspec
gemspec

gem "rspec", "=1.3.2", git: 'https://github.com/makandra/rspec.git', branch: '1-3-lts'

git 'https://github.com/makandra/rails.git', :branch => '2-3-lts' do
  gem 'rails', '~>2.3.18'
  gem 'activesupport',    :require => false
  gem 'railslts-version', :require => false
end
