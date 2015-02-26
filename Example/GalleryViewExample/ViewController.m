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
			[UIImage imageNamed:@"leaf_1.jpg"],
			[UIImage imageNamed:@"leaf_2.jpg"],
			[UIImage imageNamed:@"leaf_3.jpg"],
			[UIImage imageNamed:@"leaf_4.jpg"],
			[UIImage imageNamed:@"leaf_5.jpg"],
			[UIImage imageNamed:@"leaf_6.jpg"]
	];

	self.view.backgroundColor = [UIColor lightGrayColor];

	PAGalleryView *galleryView = [[PAGalleryView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
	galleryView.images = images;
	[self.view addSubview:galleryView];
}

@end
