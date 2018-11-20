# frozen_string_literal: true

unless Rails.env.production?
  require 'rubocop/rake_task'

  desc 'Execute rubocop -DR'
  RuboCop::RakeTask.new(:rubocop) do |tsk|
    tsk.requires << 'rubocop-rspec'
    tsk.options = ['-DR'] # rails + display cop name
  end
end
