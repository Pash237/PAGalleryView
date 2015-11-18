//
//  ViewController.m
//  GalleryFullScreenView
//
//  Created by Pavel Alexeev on 25.02.15.
//  Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "ViewController.h"
#import "PAGalleryFullScreenView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSArray *images = @[
			[[NSBundle mainBundle] URLForResource:@"leaf_1" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"leaf_2" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"leaf_3" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"leaf_4" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"leaf_5" withExtension:@"jpg"],
			[[NSBundle mainBundle] URLForResource:@"leaf_6" withExtension:@"jpg"],
	];

	self.view.backgroundColor = [UIColor lightGrayColor];

	PAGalleryView *galleryView = [[PAGalleryView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
	galleryView.imageURLs = images;
	galleryView.errorImage = [UIImage imageNamed:@"error_image.png"];
	[self.view addSubview:galleryView];
}

@end
