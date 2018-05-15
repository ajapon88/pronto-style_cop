
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pronto/style_cop/version'

Gem::Specification.new do |spec|
  spec.name          = 'pronto-style_cop'
  spec.version       = Pronto::StyleCopVersion::VERSION
  spec.authors       = ['ajapon88']
  spec.email         = ['ajapon88@gmail.com']

  spec.summary       = 'Pronto runner for StyleCop, csharp code analyzer'
  spec.description   = 'Pronto runner for StyleCop, csharp code analyzer'
  spec.homepage      = 'http://github.com/ajapon88/pronto-style_cop'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'parallel', '~> 1.12'
  spec.add_runtime_dependency 'pronto', '~> 0.9.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
