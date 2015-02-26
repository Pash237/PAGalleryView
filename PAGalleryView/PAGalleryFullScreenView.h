//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAGalleryView.h"

@class PAGalleryFullScreenView;

@interface PAGalleryFullScreenView : PAGalleryView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

+ (PAGalleryFullScreenView *)displayFromImageView:(UIImageView *)imageView images:(NSArray *)images centerImageIndex:(NSUInteger)centerIndex;
+ (PAGalleryFullScreenView *)displayFromImageView:(UIImageView *)imageView imageURLs:(NSArray *)imageURLs centerImageIndex:(NSUInteger)centerIndex;

@end