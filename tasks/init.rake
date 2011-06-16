# -*- ruby -*-

desc "Initializa the repository"
task :init do
  bundle = ENV['BUNDLER'] || 'bundle'
  sh "#{bundle} --binstubs"
  mkdir ".chef" unless File.directory? ".chef"
  chmod 0700, ".chef"
end
