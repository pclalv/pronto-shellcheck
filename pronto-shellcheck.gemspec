# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'pronto/shellcheck_version'

Gem::Specification.new do |s|
  s.name = 'pronto-shellcheck'
  s.version = Pronto::ShellCheckVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = 'Paul Alvarez'
  s.summary = <<-EOF
    Pronto runner for ShellCheck
  EOF

  s.required_ruby_version = '>= 2.0.0'
  s.rubygems_version = '2.5.1'

  s.files = Dir['lib/**/*'] + %w(README.md)
  s.extra_rdoc_files = %w(README.md)
  s.require_paths = %w(lib)
  s.requirements << 'shellcheck (in PATH)'

  s.add_dependency('pronto', '> 0.9.0', '< 0.12.0')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('pry-byebug')
end
