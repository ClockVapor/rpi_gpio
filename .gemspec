Gem::Specification.new do |s|
  s.name = 'rpi_gpio'
  s.version = '0.1.0'
  s.licenses = ['MIT']
  s.summary = 'Ruby conversion of RPi.GPIO Python module'
  s.authors = ['Nick Lowery']
  s.platform = Gem::Platform::CURRENT
  s.email = 'nick.a.lowery@gmail.com'
  s.files = Dir.glob(["{lib,ext}/**/*", 'Gemfile*', 'Rakefile',
    'LICENSE', 'README.md'])
  s.homepage = 'https://github.com/ClockVapor/rpi_gpio'
end
