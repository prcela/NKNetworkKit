#
# Be sure to run `pod lib lint NKNetworkKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NKNetworkKit"
  s.version          = "0.1.0"
  s.summary          = "Hides the coplexity behind the network operations with swift."
  s.description      = <<-DESC
                       Hides the coplexity behind the network operations with swift. 
                       The network requests are added to NSOperationQueue so they are evaluated asynchronously.
                       Simple closures for handling success, failure and finish events.
                       Observing mechanism for downloading progress.
                       DESC
  s.homepage         = "https://github.com/prcela/NKNetworkKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "prcela" => "kresimir.prcela@gmail.com" }
  s.source           = { :git => "https://github.com/prcela/NKNetworkKit.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'NKNetworkKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Reachability', '~> 3.2'
end
