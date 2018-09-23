$:.push File.expand_path("../lib", __FILE__)
require 'offsite_payments_liqpay_v3/version'

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'offsite_payments_liqpay_v3'
  s.version      = OffsitePaymentsLiqpayV3::VERSION
  s.date         = '2018-09-16'
  s.summary      = 'Liqpay (v3) integration for the activemerchant offsite_payments gem.'
  s.description  = 'This gem extends the activemerchant offsite_payments gem ' \
                   'providing integration of Liqpay (v3).'
  s.license      = 'MIT'

  s.author = 'Michał Bajur'
  s.email = 'mbajur@gmail.com'
  s.homepage = 'https://github.com/mbajur/offsite_payments_liqpay_v3'

  s.files = Dir['README.md', 'MIT-LICENSE', 'lib/**/*']
  s.require_path = 'lib'

  s.add_dependency('offsite_payments')
  s.add_development_dependency('money')
  s.add_development_dependency('rake')
  s.add_development_dependency('test-unit', '~> 3.0')
end
