require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task :install => :build do
  puts `puppet module install -f pkg/centurylink-clc-*.tar.gz`
end

desc "Run unit spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_unit_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Run integration spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_integration_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/integration/**/*_spec.rb'
end
task :spec_integration_standalone => :install

task(:spec_standalone).clear
desc "Run unit spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_standalone) do |t|
  t.rspec_opts = ['--color', '--order', 'rand']
  t.verbose = false
  t.pattern = 'spec/{unit,integration}/**/*_spec.rb'
end
task :spec_standalone => :install

namespace :spec do
  desc "Run unit spec tests in a clean fixtures directory"
  task :unit => [:spec_prep, :spec_unit_standalone, :spec_clean]

  desc "Run integration spec tests in a clean fixtures directory"
  task :integration => [:spec_prep, :spec_integration_standalone, :spec_clean]

  namespace :integration do
    desc "Cleanup after failed integration specs"
    task :clean do
      puts `ls examples/**/*down.pp | xargs -n 1 puppet apply`
    end
  end
end

desc "Run lint and spec tests and check metadata format"
task :test => [
  :syntax,
  :lint,
  :metadata,
  :spec
]

task :default => :spec
