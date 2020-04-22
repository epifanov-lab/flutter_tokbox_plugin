#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_tokbox_plugin.podspec' to validate before publishing.
#
require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')
openTokLibraryVersion = '2.16.3'

Pod::Spec.new do |s|
  s.name             = 'flutter_tokbox_plugin'
  s.version          = '0.0.5'
  s.summary          = 'flutter_tokbox_plugin'
  s.description      = <<-DESC
flutter_tokbox_plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'OpenTok', openTokLibraryVersion
  s.dependency 'SnapKit'
  s.static_framework = true
  s.platform = :ios, '9.3'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  #s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  #s.swift_version = '5.0'
  #s.ios.deployment_target = '10.0'
  s.prepare_command = <<-CMD
        echo // Generated file, do not edit > Classes/UserAgent.h
        echo "#define LIBRARY_VERSION @\\"#{libraryVersion}\\"" >> Classes/UserAgent.h
        echo "#define LIBRARY_NAME @\\"flutter_opentok\\"" >> Classes/UserAgent.h
        echo "#define OPENTOK_LIBRARY_VERSION @\\"#{openTokLibraryVersion}\\"" >> Classes/UserAgent.h
    CMD
end
