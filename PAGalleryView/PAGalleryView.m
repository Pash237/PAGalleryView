//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PAGalleryView.h"
#import "PAGalleryFullScreenView.h"
#import "UIImageView+PAActivityIndicator.h"

@interface PAGalleryView ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *imageViews;

@property (nonatomic) int previousImageOnLeft;
@property (nonatomic) int previousImageOnRight;

- (void)didShowPageWithIndex:(NSUInteger)index;
- (void)didHidePageWithIndex:(NSUInteger)index;
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

		for (NSUInteger i = 0; i < self.imageViews.count; i++) {
			UIImageView *imageView = self.imageViews[i];
			imageView.frame = CGRectMake(width * i, 0, width, height);
		}

		self.scrollView.contentOffset = CGPointMake(width * self.currentIndex, 0);
		self.scrollView.contentSize = CGSizeMake(width * self.imageViews.count, height);
	}
}


- (void)setFrame:(CGRect)frame
{
	self.scrollView.delegate = nil;
	[super setFrame:frame];
	self.scrollView.delegate = self;
}


- (void)setupViewsForImageCount:(NSUInteger)imageCount
{
	//remove old views
	for (UIView *imageView in self.imageViews) {
		[imageView removeFromSuperview];
	}

	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	self.imageViews = [NSMutableArray arrayWithCapacity:imageCount];

	self.scrollView.contentSize = CGSizeMake(width * imageCount, height);

	for (NSUInteger i=0; i<imageCount; i++) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = i;
		[self.imageViews addObject:imageView];
		[self.scrollView addSubview:imageView];

		imageView.userInteractionEnabled = YES;
		[imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)]];
	}
}

- (void)setImageURLs:(NSArray *)imageURLs
{
	_imageURLs = imageURLs;
	[self setupViewsForImageCount:imageURLs.count];
	[self reloadImages];
}


- (void)setCurrentIndex:(NSUInteger)currentIndex
{
	[self setCenterIndex:currentIndex animated:NO];
	[self reloadImages];
}

- (void)setCenterIndex:(NSUInteger)centerIndex animated:(BOOL)animated
{
	_currentIndex = centerIndex;

	CGFloat width = self.scrollView.frame.size.width;
	[self.scrollView setContentOffset:CGPointMake(width * centerIndex, 0) animated:animated];
}

- (void)reloadImages
{
	NSInteger centerImage = self.currentIndex;

	for (NSInteger i=MAX(centerImage - 1, 0); i<=centerImage + 1 && i<self.imageViews.count; i++) {
		[self didHidePageWithIndex:i];
		[self didShowPageWithIndex:i];
	}
}

- (UIImageView *)imageViewAtIndex:(NSUInteger)index
{
	return self.imageViews[index];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView != self.scrollView)
		return;

	CGFloat width = scrollView.frame.size.width;
	CGFloat gap = width * 0.2f;
	int imageOnLeft = (int)((scrollView.contentOffset.x - gap) / width);
	int imageOnRight = (int)((scrollView.contentOffset.x + width + gap) / width);

	if (imageOnLeft > _previousImageOnLeft) {
		if (_previousImageOnLeft >= 0 && _previousImageOnLeft < self.imageViews.count) {
			[self didHidePageWithIndex:(NSUInteger)_previousImageOnLeft];
		}
	}
	if (imageOnRight < _previousImageOnRight) {
		if (_previousImageOnRight >= 0 && _previousImageOnRight < self.imageViews.count) {
			[self didHidePageWithIndex:(NSUInteger)_previousImageOnRight];
		}
	}
	if (imageOnLeft < _previousImageOnLeft) {
		if (imageOnLeft >= 0 && imageOnLeft < self.imageViews.count) {
			[self didShowPageWithIndex:(NSUInteger)imageOnLeft];
		}
	}
	if (imageOnRight > _previousImageOnRight) {
		if (imageOnRight >= 0 && imageOnRight < self.imageViews.count) {
			[self didShowPageWithIndex:(NSUInteger)imageOnRight];
		}
	}

	self.previousImageOnLeft = imageOnLeft;
	self.previousImageOnRight = imageOnRight;

	//get center image index
	NSInteger index = (NSInteger)((self.scrollView.contentOffset.x + width/2) / width);
	if (index < 0) index = 0;
	if (index > self.imageViews.count - 1) index = self.imageViews.count - 1;
	if (_currentIndex != index) {
		_currentIndex = (NSUInteger)index;

		if ([self.delegate respondsToSelector:@selector(galleryView:didChangeImage:)]) {
			[self.delegate galleryView:self didChangeImage:_currentIndex];
		}
	}
}

- (void)didShowPageWithIndex:(NSUInteger)index
{
	NSURL *url = self.imageURLs[index];
	UIImageView *imageView = [self imageViewAtIndex:index];

	__weak PAGalleryView *weakSelf = self;

	[imageView showActivityIndicator];
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		//TODO: check if the image is still onscreen
		UIImageView *theImageView = [weakSelf imageViewAtIndex:index];
	    [theImageView hideActivityIndicator];
	    theImageView.image = image;
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
	    UIImageView *theImageView = [weakSelf imageViewAtIndex:index];
	    [theImageView hideActivityIndicator];
	    theImageView.image = nil;
	}];
}

- (void)didHidePageWithIndex:(NSUInteger)index
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

	NSArray *imageURLs = self.imageURLs;
	if (self.fullScreenImageURLs) {
		imageURLs = self.fullScreenImageURLs;
	}

	PAGalleryFullScreenView *galleryView = [PAGalleryFullScreenView displayFromImageView:imageView imageURLs:imageURLs centerImageIndex:(NSUInteger)imageView.tag];
	galleryView.delegate = self;
}

- (void)galleryView:(PAGalleryView *)galleryView didChangeImage:(NSUInteger)index
{
	self.currentIndex = index;
}


@end