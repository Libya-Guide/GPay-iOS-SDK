Pod::Spec.new do |s|
  s.name             = "GPay_iOS_SDK"
  s.version          = "0.1.0"
  s.summary          = "This is the official Libya Guide GPay SDK for iOS. It allows you to easily integrate the GPay payment portal into your iOS app."
  s.description      = <<-DESC
This is the official Libya Guide GPay SDK for iOS. It allows you to easily integrate the GPay payment portal into your iOS app.
                   DESC
  s.homepage         = "https://github.com/Libya-Guide/GPay-iOS-SDK.git"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Basem Elazzabi" => "basim@libyaguide.net" }
  s.source           = { :git => "https://github.com/Libya-Guide/GPay-iOS-SDK.git", :tag => s.version.to_s }
  s.ios.deployment_target = "14.0"
  s.swift_version    = "5.0"
  s.source_files     = "Sources/GPay_iOS_SDK/**/*.{swift}"
  s.frameworks       = ["UIKit", "WebKit", "SwiftUI"]
  s.requires_arc     = true
end
