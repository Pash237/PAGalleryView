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
@property (nonatomic, weak) IBOutlet PAGalleryView *galleryView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *images = @[
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/6832/waterfall-beauty-lets-explore-lets-get-lost.jpg?h=150&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/237301/pexels-photo-237301.jpeg?h=150&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/210186/pexels-photo-210186.jpeg?h=150&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/62627/niagara-cases-water-waterfall-62627.jpeg?h=150&%d", (int)arc4random_uniform(10000)]]
    ];
    
    NSArray *fullScreenImages = @[
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/6832/waterfall-beauty-lets-explore-lets-get-lost.jpg?w=940&h=650&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/237301/pexels-photo-237301.jpeg?w=940&h=650&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/210186/pexels-photo-210186.jpeg?w=940&h=650&%d", (int)arc4random_uniform(10000)]],
                [NSURL URLWithString:[NSString stringWithFormat:@"https://images.pexels.com/photos/62627/niagara-cases-water-waterfall-62627.jpeg?w=940&h=650&%d", (int)arc4random_uniform(10000)]]
    ];

    
	self.galleryView.imageURLs = images;
	self.galleryView.fullScreenImageURLs = fullScreenImages;
	self.galleryView.errorImage = [UIImage imageNamed:@"error_image.png"];
}

@end
