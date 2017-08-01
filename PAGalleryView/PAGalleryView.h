//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAGalleryView;

@protocol PAGalleryViewDelegate <NSObject>
@optional
- (BOOL)galleryView:(PAGalleryView *)galleryView didSelectImage:(NSUInteger)index;
- (void)galleryView:(PAGalleryView *)galleryView didChangeImage:(NSUInteger)index;
@end

@interface PAGalleryView : UIView <UIScrollViewDelegate, PAGalleryViewDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, weak) id<PAGalleryViewDelegate> delegate;

@property (nonatomic) NSArray<NSURL *> *imageURLs;
@property (nonatomic) NSArray<NSURL *> *fullScreenImageURLs;
@property (nonatomic) UIImage *errorImage;

@property (nonatomic) BOOL closeAlignment;
@property (nonatomic) CGFloat imageSpacing;

- (UIImageView *)imageViewAtIndex:(NSUInteger)index;

@end
