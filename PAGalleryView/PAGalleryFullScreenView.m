//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "PAGalleryFullScreenView.h"

@interface PAGalleryView ()
- (void)setupViewsForImageCount:(NSUInteger)imageCount;
- (void)didShowPageWithIndex:(NSUInteger)index;
- (void)didHidePageWithIndex:(NSUInteger)index;
@end


@interface PAGalleryFullScreenView ()

@property (nonatomic) UIView *darkness;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *scrollViews;
@property (nonatomic) NSMutableArray *imageViews;
@property (nonatomic) CGRect parkingFrame;
@property (nonatomic) BOOL statusBarWasHidden;

@end

@implementation PAGalleryFullScreenView

+ (PAGalleryFullScreenView *)displayFromImageView:(UIImageView *)imageView images:(NSArray *)images centerImageIndex:(NSUInteger)centerIndex;
{
	UIView *root = [UIApplication sharedApplication].windows[0];
	CGRect rectInRoot = [imageView convertRect:imageView.bounds toView:root];

	PAGalleryFullScreenView *galleryView = [[PAGalleryFullScreenView alloc] initWithFrame:rectInRoot];
	[root addSubview:galleryView];

	galleryView.currentIndex = centerIndex;
	galleryView.images = images;
	galleryView.darkness.alpha = 0;

	//hack to fix scroll view content offset animation issue
	galleryView.scrollView.contentSize = CGSizeMake(galleryView.frame.size.width * images.count + root.frame.size.width * 2, galleryView.frame.size.height);

	galleryView.statusBarWasHidden = [UIApplication sharedApplication].isStatusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

	[UIView animateWithDuration:0.3 animations:^{
	    galleryView.darkness.alpha = 1;
	    galleryView.frame = root.bounds;
	}];

	return galleryView;
}

+ (PAGalleryFullScreenView *)displayFromImageView:(UIImageView *)imageView imageURLs:(NSArray *)imageURLs centerImageIndex:(NSUInteger)centerIndex
{
	PAGalleryFullScreenView *galleryView = [PAGalleryFullScreenView displayFromImageView:imageView images:nil centerImageIndex:centerIndex];
	galleryView.imageURLs = imageURLs;
	return galleryView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.parkingFrame = frame;

		self.darkness = [[UIView alloc] initWithFrame:CGRectMake(-10000, -10000, 20000, 20000)];
		self.darkness.backgroundColor = [UIColor blackColor];
		[self insertSubview:self.darkness atIndex:0];

		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		UIPanGestureRecognizer *hideGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanToHide:)];
		hideGestureRecognizer.delegate = self;
		[self.scrollView addGestureRecognizer:hideGestureRecognizer];

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}

	return self;
}

- (void)setupViewsForImageCount:(NSUInteger)imageCount
{
	//remove old views
	for (UIView *scrollView in self.scrollViews) {
		[scrollView removeFromSuperview];
	}

	self.imageViews = [NSMutableArray arrayWithCapacity:imageCount];
	self.scrollViews = [NSMutableArray arrayWithCapacity:imageCount];

	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	self.scrollView.contentSize = CGSizeMake(width * imageCount, height);

	for (int i=0; i<imageCount; i++) {
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		scrollView.tag = i;
		scrollView.minimumZoomScale = 1;
		scrollView.maximumZoomScale = 10.0;
		scrollView.delegate = self;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		[self.scrollViews addObject:scrollView];
		[self.scrollView addSubview:scrollView];

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = i;
		[self.imageViews addObject:imageView];
		[scrollView addSubview:imageView];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	for (NSUInteger i=0; i<self.scrollViews.count; i++) {
		UIScrollView *zoomScrollView = self.scrollViews[i];
		zoomScrollView.frame = CGRectMake(width * i, 0, width, height);
	}

	self.scrollView.contentOffset = CGPointMake(width * self.currentIndex, 0);
	self.scrollView.contentSize = CGSizeMake(width * self.scrollViews.count, height);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if (scrollView == self.scrollView)
		return nil;

	NSInteger imageIndex = scrollView.tag;
	return [self imageViewAtIndex:imageIndex];
}

- (void)didPanToHide:(UIPanGestureRecognizer *)recognizer
{
	CGFloat threshold = 100;
	CGFloat y = [recognizer translationInView:nil].y;

	if (recognizer.state == UIGestureRecognizerStateChanged) {
		self.scrollView.frame = CGRectMake(
				self.scrollView.frame.origin.x,
				y,
				self.scrollView.frame.size.width,
				self.scrollView.frame.size.height);

		self.darkness.alpha = 1.0f - MIN(0.5f, 0.2f * fabsf(y)/threshold);
	}

	if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
		if (fabsf(y) > threshold) {
			[self hideAnimated:YES];
		} else {
			[UIView animateWithDuration:0.3 animations:^{
			    self.darkness.alpha = 1;
			}];
		}
		[UIView animateWithDuration:0.3 animations:^{
		    self.scrollView.frame = self.bounds;
		}];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)panGestureRecognizer
{
	CGPoint velocity = [(UIPanGestureRecognizer *)panGestureRecognizer velocityInView:panGestureRecognizer.view];
	return fabs(velocity.y) > fabs(velocity.x);
}

- (void)didSingleTap:(UITapGestureRecognizer *)recognizer
{
	[self hideAnimated:YES];
}

- (void)didHidePageWithIndex:(NSUInteger)index
{
	[super didHidePageWithIndex:index];

	//reset zoom
	((UIScrollView *)self.scrollViews[index]).zoomScale = 1;
}

- (void)hideAnimated:(BOOL)animated
{
	if (!self.statusBarWasHidden) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}

	if (!animated) {
		[self removeFromSuperview];
	} else {
		for (UIScrollView *zoomScrollView in self.scrollViews) {
			[zoomScrollView setZoomScale:1 animated:YES];
		}
		[UIView animateWithDuration:0.3 animations:^{
		    self.frame = self.parkingFrame;
		    self.darkness.alpha = 0;
		    [self layoutIfNeeded];
		} completion:^(BOOL completed) {
		    [self removeFromSuperview];
		}];
	}
}

@end