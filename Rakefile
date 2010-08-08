require 'rubygems'
require 'rake'


# require 'bundler'
# begin
#   Bundler.setup(:runtime, :development)
# rescue Bundler::BundlerError => e
#   $stderr.puts e.message
#   $stderr.puts "Run `bundle install` to install missing gems"
#   exit e.status_code
# end



require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "launchr"
  gem.summary = %Q{Dreamcat4's launchr. For managing launchd plists}
  gem.description = %Q{--In development-- Launchr is meant as an easy-to-use stand in replacement for launchctl. Launchr is a companion tool to Brew (Mac Homebrew). Install launchr to manage launchd services in a convenient way.}
  gem.email = "dreamcat4@gmail.com"
  gem.homepage = "http://github.com/dreamcat4/launchr"
  gem.authors = ["Dreamcat4"]

  # Have dependencies? Add them to Gemfile



  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end



require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.after = lambda { `touch doc/.nojekyll` }
end

task :man do
  `cd man1 && ronn *.ronn --manual=brew --organization=Homebrew`
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end




require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)




Jeweler::GhpagesTasks.new do |ghpages|
  ghpages.push_on_release   = true
  ghpages.set_repo_homepage = true
  ghpages.user_github_com   = false
  ghpages.doc_task    = "yard"
  ghpages.keep_files  = []
  ghpages.map_paths   = {
    "doc" => "",
  }
end




task :default => :spec
