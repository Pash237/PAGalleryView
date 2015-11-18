//
//  ViewController.m
//  GalleryFullScreenView
//
//  Created by Pavel Alexeev on 25.02.15.
//  Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "ViewController.h"
#import "PAGalleryFullScreenView.h"
#import "UIImageView+AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//
//  Local images:
//
//	NSArray *images = @[
//			[[NSBundle mainBundle] URLForResource:@"leaf_1" withExtension:@"jpg"],
//			[[NSBundle mainBundle] URLForResource:@"leaf_2" withExtension:@"jpg"],
//			[[NSBundle mainBundle] URLForResource:@"leaf_3" withExtension:@"jpg"],
//			[[NSBundle mainBundle] URLForResource:@"leaf_4" withExtension:@"jpg"],
//			[[NSBundle mainBundle] URLForResource:@"leaf_5" withExtension:@"jpg"],
//			[[NSBundle mainBundle] URLForResource:@"leaf_6" withExtension:@"jpg"],
//	];

	NSArray *images = @[
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Big_Sur_June_2008.jpg/250px-Big_Sur_June_2008.jpg?%d", arc4random_uniform(10000)]],
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/McWay_Falls_04-17-2009.jpg/220px-McWay_Falls_04-17-2009.jpg?%d", arc4random_uniform(10000)]],
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Bixby_Creek_Bridge_1932..jpg/220px-Bixby_Creek_Bridge_1932..jpg?%d", arc4random_uniform(10000)]]
	];

	NSArray *fullScreenImages = @[
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/6/6b/Big_Sur_June_2008.jpg?%d", arc4random_uniform(10000)]],
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/e/e5/McWay_Falls_04-17-2009.jpg?%d", arc4random_uniform(10000)]],
			[NSURL URLWithString:[NSString stringWithFormat:@"http://upload.wikimedia.org/wikipedia/commons/5/50/Bixby_Creek_Bridge_1932..jpg?%d", arc4random_uniform(10000)]]
	];

	self.view.backgroundColor = [UIColor lightGrayColor];

	PAGalleryView *galleryView = [[PAGalleryView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
	galleryView.imageURLs = images;
	galleryView.fullScreenImageURLs = fullScreenImages;
	galleryView.errorImage = [UIImage imageNamed:@"error_image.png"];
	[self.view addSubview:galleryView];
}

@end
