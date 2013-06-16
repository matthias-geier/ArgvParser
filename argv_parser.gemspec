Gem::Specification.new do |s|
  s.name = "ArgvParser"
  s.version = '1.0.3'
  s.summary = "A basic parser for command line arguments."
  s.author = "Matthias Geier"
  s.homepage = "https://github.com/matthias-geier/ArgvParser"
  s.require_path = 'lib'
  s.files = Dir['lib/*.rb'] << "LICENSE.md"
  s.executables = []
  s.required_ruby_version = '>= 1.9.3'
end
