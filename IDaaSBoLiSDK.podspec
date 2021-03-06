#
# Be sure to run `pod lib lint IDaaSBoLiSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IDaaSBoLiSDK'
  s.version          = '0.0.3'
  s.summary          = 'A short description of IDaaSBoLiSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
描述
                       DESC

  s.homepage         = 'https://github.com/yeniugo/IDaaSBoLiSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yeniugo' => 'hukaihope@gmail.com' }
  s.source           = { :git => '/Users/hukai/Documents/git/MyRepo/IDaaSBoLiSDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'IDaaSBoLiSDK/*.{h,m}'
  s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => ["IDaaSBoLiSDK/*.h"]}
  s.resource_bundles = {
    'IDaaSBoLiSDK' => ['IDaaSBoLiSDK/Assets/*']
  }
  s.vendored_libraries = 'IDaaSBoLiSDK/*.a'
  s.libraries = 'resolv'
  s.public_header_files = 'IDaaSBoLiSDK/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'AFNetworking','3.1.0'
  s.dependency 'Masonry'
  s.dependency 'YYModel'
  s.dependency 'MBProgressHUD','1.0.0'

#  s.subspec 'Ext' do |ss|
#    ss.source_files = 'IDaaSBoLiSDK/*.{h,m}'
#    #ss.exclude_files = 'IDaaSBoLiSDK/IDaaSBoLiSDK.h'
#    ss.vendored_libraries = 'IDaaSBoLiSDK/*.a'
#    ss.frameworks = 'UIKit', 'Foundation'
#    ss.dependency 'AFNetworking','3.1.0'
#    ss.dependency 'Masonry'
#    ss.dependency 'YYModel'
#    ss.dependency 'MBProgressHUD','1.0.0'
#    ss.libraries = 'resolv'
#    s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => ["IDaaSBoLiSDK/*.h"]}
#    ss.resource_bundles = {
#      'IDaaSBoLiSDK' => ['IDaaSBoLiSDK/Assets/*']
#    }
#  end
  # s.prefix_header_contents = ['#import <UIKit/UIKit.h>', '#import <Foundation/Foundation.h>']
end
