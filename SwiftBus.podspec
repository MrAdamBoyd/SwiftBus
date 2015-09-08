Pod::Spec.new do |s|
  s.name             = "SwiftBus"
  s.version          = "1.0"
  s.summary          = "Asynchronous Swift wrapper for the NextBus API."

  s.homepage         = "https://github.com/MrAdamBoyd/SwiftBus"
  s.author           = "Adam Boyd"
  s.source           = { :git => "https://github.com/MrAdamBoyd/SwiftBus.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MrAdamBoyd'

  s.platform     = :ios, '8.0'
  #s.ios.deployment_target = "8.0"
  #s.osx.deployment_target = "10.9"
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SwiftBus' => ['Pod/Assets/*.png']
  }

  s.dependency 'SWXMLHash', '~> 1.1.0'
end




#Pod::Spec.new do |s|
#  s.name         = "SwiftBus"
#  s.version      = "1.0"
#  s.summary      = "Asynchronous Swift wrapper for the NextBus API."
#  s.homepage     = "https://github.com/MrAdamBoyd/SwiftBus"
#  s.license      = { :type => "MIT" }
#  s.author       = "Adam Boyd"
#  s.ios.deployment_target = "8.0"
#  s.osx.deployment_target = "10.9"
#
#  s.source       = { :git => "https://github.com/MrAdamBoyd/SwiftBus.git", :tag => s.version.to_s }
#  s.source_files  = "SwiftBus/Source/*.swift"
#  s.dependency 'SWXMLHash', '~> 1.1.0'

#end
