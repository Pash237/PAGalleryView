# PAGalleryView

[![Version](https://img.shields.io/cocoapods/v/PAGalleryView.svg?style=flat)](http://cocoapods.org/pods/PAGalleryView)
[![License](https://img.shields.io/cocoapods/l/PAGalleryView.svg?style=flat)](http://cocoapods.org/pods/PAGalleryView)
[![Platform](https://img.shields.io/cocoapods/p/PAGalleryView.svg?style=flat)](http://cocoapods.org/pods/PAGalleryView)

iOS library implementing fullscreen and in-place image gallery similar to Facebook and VK applications.
- Smooth animations
- Drag to exit fullscreen gesture
- Autorotate of fullscreen images (no need to support portrait & landscape modes in your ViewController)
- Activity and error indicators

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Minimum iOS Target – iOS 7.

AFNetworking is used to download images.

## Installation

PAGalleryView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PAGalleryView"
```

##Usage

Simple example:

```objective-c
	NSArray *images = @[
			[[NSBundle mainBundle] URLForResource:@"image_1" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"image_2" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"image_3" withExtension:@"jpg"],
	];

	self.galleryView.imageURLs = images;
```

Using fullscreen images:

```objective-c
	self.galleryView.imageURLs = images;
	self.galleryView.fullScreenImageURLs = fullScreenImages;
	self.galleryView.errorImage = [UIImage imageNamed:@"errorImage"];
```

## Author

Pavel Alexeev, pasha.alexeev@gmail.com

## License

PAGalleryView is available under the MIT license. See the LICENSE file for more info.
