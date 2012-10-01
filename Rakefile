require "bundler/gem_tasks"

require "rake/testtask"
namespace :test do
  Rake::TestTask.new(:rack) do |t|
    t.libs << "test"
    t.pattern = "test/*_test.rb"
    t.verbose = true
  end
end

task :test do
  Rake::Task["test:rack"].invoke
end