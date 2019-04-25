# frozen_string_literal: true

require './lib/proforma/extended_evaluator/version'

Gem::Specification.new do |s|
  s.name        = 'proforma-extended-evaluator'
  s.version     = Proforma::ExtendedEvaluator::VERSION
  s.summary     = 'Proforma evaluator plugin for nested object value resolution and text templating'

  s.description = <<-DESCRIPTION
    Proforma comes with basic object value resolution and no text templating.
    This library fills these necessities that any reasonably robust document rendering framework should have.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/proforma-extended-evaluator'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.8'

  s.add_dependency('stringento', '~>2')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('proforma', '>=1.0.0-alpha')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rubocop', '~>0.63.1')
  s.add_development_dependency('simplecov', '~>0.16.1')
  s.add_development_dependency('simplecov-console', '~>0.4.2')
end
