#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fyno_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fyno_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Flutter bridge over iOS native code'
  s.description      = <<-DESC
  A Flutter bridge for communication with native platform code through method channels in Flutter applications developed by Fyno.
                       DESC
  s.homepage         = 'https://github.com/fynoio/flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fyno' => 'viram@fyno.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'fyno-push-ios', '~> 3.6.0'

  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
