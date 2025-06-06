# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc "Run all tests and linters"
task default: %i[rubocop spec]

desc "Run tests"
task test: :spec

desc "Install dependencies"
task :install do
  system("bundle install")
end

desc "Update dependencies"
task :update do
  system("bundle update")
end