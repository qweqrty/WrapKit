Pod::Spec.new do |s|
  s.name             = "WrapKit"
  s.version          = "0.0.6"
  s.summary          = "WrapKit is a Swift Cocoa Pods Library"
  s.description      = <<-DESC
	WrapKit is a DSL to make development easier

                        DESC
  s.homepage         = "https://github.com/gitlees/WrapKit"
  s.author           = { "Stanislav Lee" => "glees769@gmail.com" }
  s.source           = { :git => "https://github.com/gitlees/WrapKit.git", :tag => s.version.to_s }
  s.license          = { :type => "MIT", :file => "LICENSE" }

  s.requires_arc          = true

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.source_files          = 'WrapKitAuth/**/*.swift', 'WrapKitNetworking/**/*.swift'

  s.swift_version = '5.0'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end