#
# Be sure to run `pod lib lint ViewVisibleTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ViewVisibleTracker'
  s.version          = '0.1.0'
  s.summary          = 'View Visible Tracker on ScrollView'

  s.description      = 'A library to keep track of all views on a scroll view.'

  s.homepage         = 'https://github.com/david/ViewVisibleTracker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'david' => 'h2s1880@gmail.com' }
  s.source           = { :git => 'https://github.com/david/ViewVisibleTracker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/ViewVisibleTracker/**/*'
end
