Pod::Spec.new do |s|
  s.name         = "SwiftBus"
  s.version      = "1.0"
  s.summary      = "Asynchronous Swift wrapper for the NextBus API."
  s.homepage     = "https://github.com/MrAdamBoyd/SwiftBus"
  s.license      = { :type => "MIT" }
  s.author       = "Adam Boyd"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "1.0"

  s.source       = { :git => "https://github.com/MrAdamBoyd/SwiftBus", :tag => s.version.to_s }
  s.source_files  = "SwiftBus/SwiftBus/*.swift"
  s.dependency 'SWXMLHash', '~> 1.1.0'

end
