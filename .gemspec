Gem::Specification.new do |s|
  s.name = 'rpi_gpio'
  s.version = '0.7.1'
  s.license = 'MIT'
  s.summary = 'Ruby conversion of RPi.GPIO Python module'
  s.description = s.summary
  s.authors = ['Nick Lowery']
  s.extensions << 'ext/rpi_gpio/extconf.rb'
  s.email = 'nick.lowery@proton.me'
  s.files = Dir.glob(['lib/**/*.rb', 'ext/**/*', 'LICENSE', 'README.md'])
  s.homepage = 'https://github.com/ClockVapor/rpi_gpio'
  s.add_runtime_dependency 'epoll', '~> 0.3'
  s.add_development_dependency 'rake-compiler', '~> 1.3'
  s.add_development_dependency 'rspec', '~> 3.13'
end

