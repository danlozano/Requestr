Pod::Spec.new do |s|
  s.name         = "TinyAPIClient"
  s.version      = "0.1.0"
  s.summary      = "Tiny (small, simple) API client for Swift."
  s.description  = <<-DESC
  Simple network library based on NSURLSession. Handles JSON mapping, among other things.
                   DESC
  s.homepage     = "http://github.com/danlozano/TinyAPIClient"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniel Lozano" => "dan@danielozano.com" }
  s.social_media_url   = "http://twitter.com/danlozanov"

  s.platform     = :ios, "9.0"
  # s.platform     = :tvos
  # s.platform     = :osx, "10.10"

  s.source       = { :git => "https://github.com/danlozano/TinyAPIClient.git", :tag => "#{s.version}" }
  s.source_files = "TinyApiClient/**/*"
  # s.public_header_files = "Filtr/Classes/**/*.h"
  # s.resources = "Filtr/Resources/**/*{xcassets,png,fcube}"

end
