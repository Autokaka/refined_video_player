#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint refined_video_player.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'refined_video_player'
  s.version          = '0.0.1'
  s.summary          = 'Refined Video Player'
  s.description      = <<-DESC
A better, highly customizable, user-friendly video player using PlatformView + SurfaceView on Android to fix https://github.com/flutter/flutter/issues/44793. IOS not implemented yet.
                       DESC
  s.homepage         = 'https://github.com/Autokaka/refined_video_player'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'MobileVLCKit', '~> 3.3.12'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
