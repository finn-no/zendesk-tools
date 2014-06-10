require 'bundler/setup'
require 'rake/clean'

CLEAN << "pkg"
CLEAN << "*.gem"

GEM_NAME = "zendesk-tools-#{ZendeskTools::VERSION}.gem"

zdt_gem = file "pkg/#{GEM_NAME}" do |t|
  mkdir_p "pkg"
  sh "gem build zendesk-tools.gemspec"
  mv GEM_NAME, t.name
end

desc "Build #{zdt_gem.name}"
task :build => [:clean, zdt_gem.name]

desc "Release #{zdt_gem.name}"
task :release => :build do
  sh "gem inabox #{zdt_gem.name}"
end
