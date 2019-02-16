Pod::Spec.new do |s|
  s.name         = "InjectableSwift"
  s.version      = "0.1.4"
  s.summary      = "A Swift dependency injection container"
  s.description  = <<-DESC
                    A Swift dependency injection container which minimises the need for centralised registration
                   DESC
  s.homepage     = "https://github.com/nicholascross/Injectable"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "Nicholas Cross"
  s.social_media_url   = "https://twitter.com/nickacross"
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "3.2"
  s.tvos.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/nicholascross/Injectable.git", :tag => "#{s.version}" }
  s.source_files  = "Injectable/**/*.swift"
  s.requires_arc = true
  s.swift_version = "4.2"
end
