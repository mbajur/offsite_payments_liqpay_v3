$:.unshift File.expand_path('../lib', __FILE__)
require 'offsite_payments_liqpay_v3/version'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
  require 'rubygems'
end

require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'

task :tag_release do
  system "git tag -a v#{OffsitePaymentsLiqpayV3::VERSION} -m 'Tagging #{OffsitePaymentsLiqpayV3::VERSION}'"
  system "git push --tags"
end

desc "Run the unit test suite"
task :default => 'test:units'
task :test => 'test:units'

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_test.rb'
    t.ruby_opts << '-rrubygems'
    t.libs << 'test'
    t.verbose = true
  end
end
