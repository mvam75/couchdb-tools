require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
$:.push File.expand_path("../lib", __FILE__)
require 'couchdb-tools/version'

gem = Gem::Specification.new do |g|
  g.name = 'couchdb-tools'
  g.version = CouchDBTools::VERSION
  g.summary = "A collection of tools for Couchdb"
  g.description = "Tools to monitor CouchDB replication"
  g.author = "thePlatform"
  g.email = "devops@theplatform.com"
  g.executables =  FileList.new('bin/**/*').gsub!(/^bin\//,'').to_a
  g.files = Dir.glob(["Rakefile", "config.json"]) + Dir.glob("lib/**/*")
  g.add_runtime_dependency 'json'
  g.add_runtime_dependency 'yajl-ruby'
  g.add_runtime_dependency 'mail'
  g.add_runtime_dependency 'rufus-scheduler'
  g.add_runtime_dependency 'rest-client'
  g.add_runtime_dependency 'eventmachine'
end

Gem::PackageTask.new(gem) do |p|
  puts("Building Gem")
  p.gem_spec = gem
  p.need_tar = true
  p.need_zip = true
 end
