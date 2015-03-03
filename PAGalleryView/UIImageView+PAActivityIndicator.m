//
// Created by Pavel Alexeev on 03.03.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <objc/runtime.h>
#import "UIImageView+PAActivityIndicator.h"

static char ActivityIndicatorStyleKey;
static char ActivityIndicatorKey;
static char ActivityIndicatorCountKey;
static NSInteger ActivityIndicatorTag = 323115;

@implementation UIImageView (PAActivityIndicator)

- (UIActivityIndicatorViewStyle)activityIndicatorStyle
{
	id value = objc_getAssociatedObject(self, &ActivityIndicatorStyleKey);
	if (!value) {
		return UIActivityIndicatorViewStyleWhite;
	} else {
		return (UIActivityIndicatorViewStyle)[value integerValue];
	}
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle
{
	objc_setAssociatedObject(self, &ActivityIndicatorStyleKey, @(activityIndicatorStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityIndicator
{
	return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &ActivityIndicatorKey);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
	objc_setAssociatedObject(self, &ActivityIndicatorKey, activityIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)activityIndicatorCount
{
	return [objc_getAssociatedObject(self, &ActivityIndicatorCountKey) integerValue];
}

- (void)setActivityIndicatorCount:(NSInteger)activityIndicatorCount
{
	objc_setAssociatedObject(self, &ActivityIndicatorCountKey, @(activityIndicatorCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


//-----------------------------------------------------------------

- (void)showActivityIndicator
{
	self.activityIndicatorCount++;

	if (!self.activityIndicator) {
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorStyle];
		activityIndicator.tag = ActivityIndicatorTag;
		activityIndicator.autoresizingMask = UIViewAutoresizingNone;
		[activityIndicator startAnimating];

		self.activityIndicator = activityIndicator;

		[self updateActivityIndicatorFrame];

	    [self addSubview:activityIndicator];
	}
}

- (void)hideActivityIndicator
{
	self.activityIndicatorCount--;

	if (self.activityIndicatorCount <= 0) {
	    if (self.activityIndicator) {
		    [self.activityIndicator removeFromSuperview];
		    self.activityIndicator = nil;
	    }
		self.activityIndicatorCount = 0;
	}
}


- (void)updateActivityIndicatorFrame
{
	if (self.activityIndicator) {
		CGSize activityIndicatorSize = self.activityIndicator.bounds.size;
		CGFloat x = roundf((self.frame.size.width - activityIndicatorSize.width) / 2.0f);
		CGFloat y = roundf((self.frame.size.height - activityIndicatorSize.height) / 2.0f);
		self.activityIndicator.frame = CGRectMake(x, y, activityIndicatorSize.width, activityIndicatorSize.height);
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	//does UIImageView do something in its layoutSubviews?
	[self updateActivityIndicatorFrame];
}


@end