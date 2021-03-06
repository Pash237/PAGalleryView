//
// Created by Pavel Alexeev on 03.03.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (PAActivityIndicator)

@property (nonatomic) UIActivityIndicatorViewStyle activityIndicatorStyle;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end