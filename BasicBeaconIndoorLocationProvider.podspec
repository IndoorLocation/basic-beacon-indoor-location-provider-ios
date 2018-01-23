Pod::Spec.new do |s|
  s.name         = "BasicBeaconIndoorLocationProvider"
  s.version      = "1.0.1"
  s.license      = { :type => 'MIT' }
  s.summary      = "Allows to use beacon from Mapwize studio to locate you"
  s.homepage     = "https://github.com/IndoorLocation/basic-beacon-indoor-location-provider-ios.git"
  s.author       = { "Indoor Location" => "indoorlocation@mapwize.io" }
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/IndoorLocation/basic-beacon-indoor-location-provider-ios.git", :tag => "#{s.version}" }
  s.source_files  = "basicbeacon-indoorlocation-provider-ios/Provider/*.{h,m}"
  s.dependency "GPSIndoorLocationProvider", "~> 1.0"
end
