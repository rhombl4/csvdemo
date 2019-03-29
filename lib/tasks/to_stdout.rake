namespace :to do
  desc 'switch logger to stdout'
  task :stdout => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end
end
