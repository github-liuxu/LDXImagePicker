Pod::Spec.new do |s|
  s.name             = "LDXImagePicker"
  s.version          = "1.1.1"
  s.summary          = "A clone of UIImagePickerController with multiple selection support."
  s.homepage         = "https://github.com/github-liuxu/LDXImagePicker"
  s.license          = "MIT"
  s.author           = { "questbeat" => "chuyang009@163.com" }
  s.source           = { :git => "https://github.com/github-liuxu/LDXImagePicker.git", :tag => "1.1.1" }
  s.social_media_url = ""
  s.source_files     = "LDXImagePicker/*.{h,m,swift}"
  s.exclude_files    = "LDXImagePicker/LDXImagePicker.h"
  s.resources        = 'LDXImagePicker/*.{lproj,storyboard,xcassets}'
  s.platform         = :ios, "9.0"
  s.requires_arc     = true
  s.frameworks       = "Photos"
end
