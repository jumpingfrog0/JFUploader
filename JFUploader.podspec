#
# Be sure to run `pod lib lint JFUploader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JFUploader'
  s.version          = '0.1.0'
  s.summary          = 'A short description of JFUploader.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Asynchronous file uploader for iOS.
                       DESC

  s.homepage         = 'https://github.com/jumpingfrog0/JFUploader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jumpingfrog0' => 'jumpingfrog0@gmail.com' }
  s.source           = { :git => 'https://github.com/jumpingfrog0/JFUploader.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JFUploader' => ['Source/Assets/*.png']
  # }

  s.public_header_files = 'Source/Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'JFUIKit', '~> 0.2.1'
end
