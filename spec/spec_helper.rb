require "bundler/setup"
require "debug"
require "ruby/pomodoro"
require 'app_helper'
require 'aasm/rspec'
require 'shared_contexts'
require 'shared_examples'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
