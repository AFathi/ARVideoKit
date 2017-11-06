Pod::Spec.new do |s|

  s.name = "ARVideoKit"
  s.version = "1.0"
  s.summary = "Enabling developers to capture media with ARKit content."
  
  s.description  = "An iOS Framework that enables developers to capture videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆 with ARKit content."
  
  s.homepage = "https://github.com/AFathi/ARVideoKit"
  
  s.screenshots  = "http://www.ahmedbekhit.com/SK_PREV.gif"

  s.author       = { "Ahmed Bekhit" => "me@ahmedbekhit.com" }
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.platform     = :ios, "11.0"

  s.source = { :http => "http://ahmedbekhit.com/ARVideoKit.zip" }
  s.module_map = "ARVideoKit.framework/Modules/module.modulemap"
  s.vendored_frameworks = "ARVideoKit.framework"

end
