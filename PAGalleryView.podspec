#
# Be sure to run `pod lib lint PAGalleryView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PAGalleryView"
  s.version          = "0.1.0"
  s.summary          = "iOS library implementing fullscreen and in-place image gallery similar to Facebook and VK applications."
  s.description      = <<-DESC
						- Smooth animations
						- Drag to exit fullscreen gesture
						- Autorotate of fullscreen images (no need to support portrait & landscape modes in your ViewController)
						- Activity and error indicators
                       DESC

  s.homepage         = "https://github.com/Pash237/PAGalleryView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Pavel Alexeev" => "pasha.alexeev@gmail.com" }
  s.source           = { :git => "https://github.com/Pash237/PAGalleryView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'PAGalleryView/**/*'

  s.dependency 'AFNetworking'
end
