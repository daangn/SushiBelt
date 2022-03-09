#
# Be sure to run `pod lib lint SushiBelt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SushiBelt'
  s.version          = '0.1.0'
  s.summary          = 'Track visible views on the UIScrollView'

  s.description      = 'The SushiBelt can be used to measure exposure according to the ratio for all views on the UIScrollView.'

  s.homepage         = 'https://github.com/david/SushiBelt'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Geektree0101' => 'h2s1880@gmail.com' }
  s.source           = { :git => 'https://github.com/david/SushiBelt.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/SushiBelt/**/*'
  s.test_spec 'SushiBeltTests' do |test_spec|
    test_spec.source_files = 'Tests/SushiBeltTests/**/*'
  end  
end
