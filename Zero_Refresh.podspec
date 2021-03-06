#
# Be sure to run `pod lib lint Zero_Refresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Zero_Refresh'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Zero_Refresh.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ZeroJian/Zero_Refresh'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZeroJian' => 'zj17223412@outlook.com' }
  s.source           = { :git => 'https://github.com/ZeroJian/Zero_Refresh.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
     ss.source_files = 'Zero_Refresh/Classes/Core/**/*'
  end
  
  s.subspec 'ExEmptyView' do |ss|
      ss.source_files = 'Zero_Refresh/Classes/ExEmptyView/**/*'
      ss.dependency 'Zero_Refresh/Core'
  end
  
  s.subspec 'BridgeMJRefresh' do |ss|
      ss.source_files = 'Zero_Refresh/Classes/BridgeMJRefresh/**/*'
      ss.dependency 'Zero_Refresh/Core'
      ss.dependency 'MJRefresh'
  end
  
  #s.source_files = 'Zero_Refresh/Classes/**/*'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  #s.dependency 'MJRefresh'
  #s.dependency 'RefreshInterpreter'

end
