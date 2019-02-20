#
# Be sure to run `pod lib lint KPFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KPFoundation'
  s.version          = '0.1.1'
  s.summary          = 'A short description of KPFoundation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kp99999/KPFoundation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'KP99999' => 'kp_ios@kp99.cn' }
  s.source           = { :git => 'https://github.com/kp99999/KPFoundation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.dependency 'FMDB'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'AFNetworking'
  s.dependency 'ZipArchive'

  s.public_header_files = 'KPFoundation/KPFoundation.h'
  s.source_files = 'KPFoundation/KPFoundation.h'
  
  s.subspec 'Module' do |ss|
      ss.public_header_files = 'KPFoundation/Module/**/*.h','KPFoundation/KPPublicDefine.h'
      ss.source_files = 'KPFoundation/Module/**/*.{h,m}','KPFoundation/KPPublicDefine.h'
      ss.requires_arc = true
  end
  
  s.subspec 'ObjSafe' do |ss|
      ss.public_header_files = 'KPFoundation/NoArc/ObjSafe/*.h'
      ss.source_files = 'KPFoundation/NoArc/ObjSafe/*.{h,m}'
      ss.requires_arc = false
  end
  
  # s.resource_bundles = {
  #   'KPFoundation' => ['KPFoundation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
