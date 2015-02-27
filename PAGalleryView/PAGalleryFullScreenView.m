//
// Created by Pavel Alexeev on 25.02.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "PAGalleryFullScreenView.h"

@interface PAGalleryView ()
- (void)setupViewsForImageCount:(NSUInteger)imageCount;
- (void)didShowPageWithIndex:(NSUInteger)index;
- (void)didHidePageWithIndex:(NSUInteger)index;
- (void)commonGalleryInit;
@end


@interface PAGalleryFullScreenView ()

@property (nonatomic) UIView *darkness;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *scrollViews;
@property (nonatomic) NSMutableArray *imageViews;
@property (nonatomic) CGRect parkingFrame;
@property (nonatomic) BOOL statusBarWasHidden;
@property (nonatomic) UIDeviceOrientation orientation;

@end

@implementation PAGalleryFullScreenView

+ (PAGalleryFullScreenView *)displayFromImageView:(UIImageView *)imageView imageURLs:(NSArray *)imageURLs centerImageIndex:(NSUInteger)centerIndex
{
	UIView *root = [UIApplication sharedApplication].windows[0];
	CGRect rectInRoot = [imageView convertRect:imageView.bounds toView:root];

	PAGalleryFullScreenView *galleryView = [[PAGalleryFullScreenView alloc] initWithFrame:rectInRoot];
	[root addSubview:galleryView];

	galleryView.currentIndex = centerIndex;
	galleryView.imageURLs = imageURLs;
	galleryView.darkness.alpha = 0;

	//hack to fix scroll view content offset animation issue
	[galleryView expandScrollViewContentSizeToMaximum];

	galleryView.statusBarWasHidden = [UIApplication sharedApplication].isStatusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

	[UIView animateWithDuration:0.3 animations:^{
	    galleryView.darkness.alpha = 1;
	    galleryView.frame = root.bounds;
	}];

	return galleryView;
}

- (void)commonGalleryInit
{
	[super commonGalleryInit];

	self.parkingFrame = self.frame;

	self.darkness = [[UIView alloc] initWithFrame:CGRectMake(-10000, -10000, 20000, 20000)];
	self.darkness.backgroundColor = [UIColor blackColor];
	[self insertSubview:self.darkness atIndex:0];

	UIPanGestureRecognizer *hideGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanToHide:)];
	hideGestureRecognizer.delegate = self;
	[self.scrollView addGestureRecognizer:hideGestureRecognizer];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
	[self addGestureRecognizer:tapGestureRecognizer];

	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
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
	if (self.orientation == UIDeviceOrientationLandscapeRight || self.orientation == UIDeviceOrientationLandscapeLeft) {
		width = self.frame.size.height;
		height = self.frame.size.width;
	}

	for (NSUInteger i=0; i<self.scrollViews.count; i++) {
		UIScrollView *zoomScrollView = self.scrollViews[i];
		zoomScrollView.frame = CGRectMake(width * i, 0, width, height);
	}

	self.scrollView.contentOffset = CGPointMake(width * self.currentIndex, 0);
	self.scrollView.contentSize = CGSizeMake(width * self.scrollViews.count, height);
}

- (void)expandScrollViewContentSizeToMaximum
{
	CGFloat width = self.superview.frame.size.width;
	CGFloat height = self.superview.frame.size.height;
	self.scrollView.contentSize = CGSizeMake(width * self.imageViews.count + width * 10, height);
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

	CGFloat shift = [recognizer translationInView:nil].y;
	if (self.orientation == UIDeviceOrientationLandscapeRight)
		shift = [recognizer translationInView:nil].x;
	if (self.orientation == UIDeviceOrientationLandscapeLeft)
		shift = -[recognizer translationInView:nil].x;
	if (self.orientation == UIDeviceOrientationPortraitUpsideDown)
		shift = -[recognizer translationInView:nil].y;

	if (recognizer.state == UIGestureRecognizerStateChanged) {
		self.scrollView.frame = CGRectMake(
				self.scrollView.frame.origin.x,
				shift,
				self.scrollView.frame.size.width,
				self.scrollView.frame.size.height);

		self.darkness.alpha = 1.0f - MIN(0.5f, 0.2f * fabsf(shift)/threshold);
	}

	if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
		if (fabsf(shift) > threshold) {
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
	if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		CGPoint velocity = [(UIPanGestureRecognizer *)panGestureRecognizer velocityInView:panGestureRecognizer.view];
		return fabs(velocity.y) > fabs(velocity.x);
	} else {
		return YES;
	}
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
		    self.transform = CGAffineTransformMakeRotation(0);
		    [self layoutIfNeeded];
		} completion:^(BOOL completed) {
		    [self removeFromSuperview];
		}];
	}
}

#pragma mark Rotation

- (void)didChangeOrientation:(NSNotification *)notification
{
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
		//hack to fix scroll view content offset animation issue
		[self expandScrollViewContentSizeToMaximum];

		[UIView animateWithDuration:0.3 animations:^{
		    switch ([UIDevice currentDevice].orientation) {
			    case UIDeviceOrientationPortrait:
				    self.transform = CGAffineTransformMakeRotation(0);
		            break;
			    case UIDeviceOrientationPortraitUpsideDown:
				    self.transform = CGAffineTransformMakeRotation(M_PI);
		            break;
			    case UIDeviceOrientationLandscapeLeft:
				    self.transform = CGAffineTransformMakeRotation(M_PI / 2);
		            break;
			    case UIDeviceOrientationLandscapeRight:
				    self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		            break;
			    default:
				    break;
		    }

		    self.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
		    self.orientation = [UIDevice currentDevice].orientation;
		}];
	}
}

- (void)dealloc
{
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end