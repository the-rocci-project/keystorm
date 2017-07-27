unless Rails.env.production?
  desc 'Run acceptance tests (spec + rbp + rubocop)'
  task acceptance: %i[spec rbp rubocop]
end
