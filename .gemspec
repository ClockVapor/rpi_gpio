Gem::Specification.new do |s|
  s.name = 'rpi_gpio'
  s.version = '0.1.2'
  s.licenses = ['MIT']
  s.summary = 'Ruby conversion of RPi.GPIO Python module'
  s.description = s.summary
  s.authors = ['Nick Lowery']
  s.extensions << 'ext/rpi_gpio/extconf.rb'
  s.email = 'nick.a.lowery@gmail.com'
  s.files = Dir.glob(["{lib,ext}/**/*", 'Gemfile*', 'Rakefile',
    'LICENSE', 'README.md'])
  s.homepage = 'https://github.com/ClockVapor/rpi_gpio'
end
