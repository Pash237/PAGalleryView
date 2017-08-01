//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PAGalleryView.h"
#import "PAGalleryFullScreenView.h"
#import "UIImageView+PAActivityIndicator.h"

@interface PAGalleryFullScreenView ()
@property (nonatomic) CGRect parkingFrame;
@end

@interface PAGalleryView ()

@property (nonatomic, readwrite) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, weak) PAGalleryFullScreenView *fullScreenGalleryView;

@property (nonatomic) NSMutableArray<NSNumber *> *visibleImages;
@property (nonatomic) NSMutableArray<NSValue *> *imagesSize;

- (void)didShowImageWithIndex:(NSUInteger)index;
- (void)didHideImageWithIndex:(NSUInteger)index;
- (void)commonGalleryInit;

@end

@implementation PAGalleryView

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self commonGalleryInit];
	}

	return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonGalleryInit];
	}

	return self;
}

- (void)commonGalleryInit
{
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	self.scrollView.pagingEnabled = YES;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.delegate = self;
	[self addSubview:self.scrollView];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	if (![self isMemberOfClass:[PAGalleryFullScreenView class]]) {
		CGFloat width = self.frame.size.width;
		CGFloat height = self.frame.size.height;
        CGFloat currentX = 0;
        CGFloat currentImageX = 0;

		for (NSUInteger i = 0; i < self.imageViews.count; i++) {
			UIImageView *imageView = self.imageViews[i];
            if (self.closeAlignment) {
                CGSize imageSize = [self.imagesSize[i] CGSizeValue];
                CGFloat imageWidth = height * imageSize.width/imageSize.height;
                imageView.frame = CGRectMake(currentX, 0, imageWidth, height);
	            if (i != self.imageViews.count - 1) {
		            currentX += self.imageSpacing;
	            }
            } else {
                imageView.frame = CGRectMake(width * i, 0, width, height);
            }
            if (i == self.currentIndex) {
                currentImageX = currentX;
            }
            currentX += imageView.frame.size.width;
		}
        
        CGFloat totalWidth = currentX;

		if (!self.closeAlignment) {
			self.scrollView.contentOffset = CGPointMake(currentImageX, 0);
		}
		self.scrollView.contentSize = CGSizeMake(totalWidth, height);
		
		[self loadImagesIfVisible];
	}
}

- (void)setCloseAlignment:(BOOL)closeAlignment
{
    _closeAlignment = closeAlignment;
    self.scrollView.pagingEnabled = !closeAlignment;
}

- (void)setFrame:(CGRect)frame
{
	self.scrollView.delegate = nil;
	[super setFrame:frame];
	self.scrollView.delegate = self;
}


- (void)setupViewsForImageCount:(NSUInteger)imageCount
{
	//TODO: reuse views to perform faster on table view cells

	//remove old views
	for (UIView *imageView in self.imageViews) {
		[imageView removeFromSuperview];
	}

	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	self.imageViews = [NSMutableArray arrayWithCapacity:imageCount];
	self.imagesSize = [NSMutableArray arrayWithCapacity:imageCount];

	self.scrollView.contentSize = CGSizeMake(width * imageCount, height);
	
	CGFloat emptyImageWidth = roundf(height*1.3333f);

	for (NSUInteger i=0; i<imageCount; i++) {
		CGFloat imageViewWidth = self.closeAlignment ? emptyImageWidth : width;
		
		[self.imagesSize addObject:[NSValue valueWithCGSize:CGSizeMake(imageViewWidth, height)]];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, height)];
		imageView.tag = i;
		[self.imageViews addObject:imageView];
		[self.scrollView addSubview:imageView];

		imageView.userInteractionEnabled = YES;
		[imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)]];
	}
}

- (void)checkImagesVisibility
{
	CGFloat gap = self.closeAlignment ? 1 : self.imagesSize.firstObject.CGSizeValue.width * 0.2f;
	
	for (NSUInteger i=0; i<self.imageViews.count; i++) {
		CGRect frame = [self.imageViews[i] convertRect:self.imageViews[i].bounds toView:self];
		BOOL isVisible = (frame.origin.x <= self.scrollView.frame.size.width + gap &&
				frame.origin.x + frame.size.width > -gap);
		self.visibleImages[i] = @(isVisible);
	}
}

- (void)setImageURLs:(NSArray *)imageURLs
{
	_imageURLs = imageURLs;
	[self setupViewsForImageCount:imageURLs.count];
	
	if (self.visibleImages.count != self.imageURLs.count) {
		self.visibleImages = [NSMutableArray arrayWithCapacity:self.imageURLs.count];
		for (NSUInteger i=0; i<self.imageURLs.count; i++) {
			[self.visibleImages addObject:@NO];
		}
	}
	
	if (_currentIndex > imageURLs.count - 1) {
		self.currentIndex = imageURLs.count - 1;
	} else {
		[self loadImagesIfVisible];
	}
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
	if (self.currentIndex != currentIndex) {
		[self setCenterIndex:currentIndex animated:NO];
		[self loadImagesIfVisible];
	}
}

- (void)setCenterIndex:(NSUInteger)centerIndex animated:(BOOL)animated
{
	_currentIndex = centerIndex;

	CGFloat width = self.scrollView.frame.size.width;

	if (self.closeAlignment) {
		CGRect rect = [self.imageViews[centerIndex] convertRect:self.imageViews[centerIndex].bounds toView:self.scrollView];
		[self.scrollView scrollRectToVisible:rect animated:animated];
		self.fullScreenGalleryView.parkingFrame = [self.imageViews[centerIndex] convertRect:self.imageViews[centerIndex].bounds toView:self.fullScreenGalleryView.superview];
	} else {
		[self.scrollView setContentOffset:CGPointMake(width * centerIndex, 0) animated:animated];
	}
}

- (void)loadImagesIfVisible
{
	NSArray *previouslyVisibleImages = [[NSArray alloc] initWithArray:self.visibleImages copyItems:YES];
	[self checkImagesVisibility];
	
	for (NSUInteger i=0; i<self.imageViews.count; i++) {
		BOOL isVisible = [self.visibleImages[i] boolValue];
		BOOL wasVisible = [previouslyVisibleImages[i] boolValue];
		
		if (isVisible && !wasVisible) {
			[self didShowImageWithIndex:i];
		}
		if (!isVisible && wasVisible) {
			[self didHideImageWithIndex:i];
		}
	}
}

- (UIImageView *)imageViewAtIndex:(NSUInteger)index
{
	if (index < self.imageViews.count) {
		return self.imageViews[index];
	} else {
		return nil;
	}
}

- (NSInteger)imageAtX:(CGFloat)x
{
	if (self.closeAlignment) {
		CGFloat currentX = 0;
		
		for (NSUInteger i = 0; i < self.imageViews.count; i++) {
			currentX += self.imageViews[i].frame.size.width + self.imageSpacing;
			if (currentX > self.scrollView.contentOffset.x + x) {
				return i;
			}
		}
		return 0;
	} else {
		return (NSInteger)((self.scrollView.contentOffset.x + x) / self.scrollView.frame.size.width);
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView != self.scrollView)
		return;
	
	[self loadImagesIfVisible];

	//get center image index
	NSInteger index = [self imageAtX:5];
	if (index < 0) index = 0;
	if (index > self.imageViews.count - 1) index = self.imageViews.count - 1;
	if (_currentIndex != index) {
		_currentIndex = (NSUInteger)index;

		if ([self.delegate respondsToSelector:@selector(galleryView:didChangeImage:)]) {
			[self.delegate galleryView:self didChangeImage:_currentIndex];
		}
	}
}

- (void)didShowImageWithIndex:(NSUInteger)index
{
	NSURL *url = self.imageURLs[index];
	UIImageView *imageView = [self imageViewAtIndex:index];

	__weak PAGalleryView *weakSelf = self;

	[imageView showActivityIndicator];
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		//TODO: check if the image is still onscreen
		UIImageView *theImageView = [weakSelf imageViewAtIndex:index];
	    [theImageView hideActivityIndicator];
		theImageView.contentMode = UIViewContentModeScaleAspectFit;
	    theImageView.image = image;
		
		weakSelf.imagesSize[index] = [NSValue valueWithCGSize:image.size];
        
        if (weakSelf.closeAlignment) {
            [weakSelf setNeedsLayout];
        }
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
	    UIImageView *theImageView = [weakSelf imageViewAtIndex:index];
	    [theImageView hideActivityIndicator];
		theImageView.contentMode = UIViewContentModeCenter;
	    theImageView.image = weakSelf.errorImage;
	}];
}

- (void)didHideImageWithIndex:(NSUInteger)index
{
	UIImageView *imageView = [self imageViewAtIndex:index];
	if (imageView.image) {
		imageView.image = nil;
		[imageView hideActivityIndicator];
	}
}

- (void)didSingleTap:(UITapGestureRecognizer *)recognizer
{
	UIImageView *imageView = (UIImageView *)recognizer.view;
	NSUInteger imageIndex = (NSUInteger)imageView.tag;

	BOOL shouldOpenFullScreenView = YES;    //by default
	if ([self.delegate respondsToSelector:@selector(galleryView:didSelectImage:)]) {
		shouldOpenFullScreenView = [self.delegate galleryView:self didSelectImage:imageIndex];
	}

	if (imageIndex >= self.fullScreenImageURLs.count) {
		//for some reason full screen image count are less than normal images – don't popup fullscreen view
		shouldOpenFullScreenView = NO;
	}

	if (imageView.image == self.errorImage && !imageView.isLoading) {
		//image did not load – seems like it doesn't exists
		shouldOpenFullScreenView = NO;
	}

	if (shouldOpenFullScreenView) {
		NSArray *imageURLs = self.imageURLs;
		if (self.fullScreenImageURLs) {
			imageURLs = self.fullScreenImageURLs;
		}

		self.fullScreenGalleryView = [PAGalleryFullScreenView displayFromImageView:imageView imageURLs:imageURLs centerImageIndex:imageIndex];
		self.fullScreenGalleryView.errorImage = self.errorImage;
		self.fullScreenGalleryView.delegate = self;
	}
}

/**
 * fullscreen gallery delegate
 */
- (void)galleryView:(PAGalleryView *)galleryView didChangeImage:(NSUInteger)index
{
	self.currentIndex = index;

	if ([self.delegate respondsToSelector:@selector(galleryView:didChangeImage:)]) {
		[self.delegate galleryView:self didChangeImage:_currentIndex];
	}
}


@end
