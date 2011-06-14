# -*- ruby -*-

desc "Initializa the repository"
task :init do
  bundle = ENV['BUNDLER'] || 'bundle'
  sh "#{bundle} --binstubs"
end
