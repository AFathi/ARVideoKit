Pod::Spec.new do |s|
  s.name         = "ARVideoKit - Swift 4.2"
  s.version      = "1.5"
  s.summary      = "Capture & record ARKit videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆."
  s.description  = "Enabling developers to capture videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆 with augmented reality components."
  s.homepage     = "https://github.com/AFathi/ARVideoKit"
  s.screenshots  = "http://www.ahmedbekhit.com/SK_PREV.gif", "http://www.ahmedbekhit.com/SCN_PREVIEW.gif"
  s.swift_version = '4.2'


  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }


  s.author             = { "Ahmed Fathi Bekhit" => "me@ahmedbekhit.com" }
  s.social_media_url   = "http://ahmedbekhit.com"

  s.platform     = :ios, "11.0"

  # ARVideoKit for Swift 4.2
  s.source       = { :git => "https://github.com/AFathi/ARVideoKit.git", :tag => "1.5" }
  s.source_files  = "ARVideoKit", "ARVideoKit/**/*.{h,m,swift}"
  s.resources = "ARVideoKit/Assets/*.scnassets"
end
