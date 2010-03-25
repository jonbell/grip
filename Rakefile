require 'rubygems'
require 'rake'

require File.join(File.dirname(__FILE__), 'lib', 'grip', 'version')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "jonbell-grip"
    gem.summary     = %Q{Attachment plugin for MongoMapper that uses GridFS.}
    gem.description = %Q{Attachment plugin for MongoMapper that uses GridFS.}
    gem.email       = "nunemaker@gmail.com"
    gem.homepage    = "http://github.com/jonbell/grip"
    gem.authors     = ["John Nunemaker", "Jonathan Bell"]
    gem.version     = Grip::Version

    gem.add_dependency 'wand', '>= 0.2.1'
    gem.add_development_dependency 'mongo_mapper', '0.7.1'
    gem.add_development_dependency 'shoulda'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.ruby_opts << '-rubygems'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "grip #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
