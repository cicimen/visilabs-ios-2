Pod::Spec.new do |spec|
spec.name         = "VisilabsIOSNew"
spec.version      = "1.0.0"
spec.summary      = "VisilabsIOSNew"
spec.description  = "VisilabsIOSNew"
spec.homepage     = "https://www.VisilabsIOSNew.com"
spec.license      = { :type => "MIT", :file => "LICENSE" }
spec.author             = { "author" => "VisilabsIOSNew@VisilabsIOSNew.com" }
spec.documentation_url = "https://link_to_documentation.com"
spec.platforms = { :ios => "10.0"}
spec.swift_version = "5.0"
spec.source       = { :git => "https://github.com/cicimen/visilabs-ios-2.git", :tag => "#{spec.version}" }
spec.source_files  = "Sources/VisilabsIOSNew/**/*.swift"
spec.xcconfig = { "SWIFT_VERSION" => "5.0" }
end
