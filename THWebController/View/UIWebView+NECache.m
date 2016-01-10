//
//  UIWebView+NECache.m
//  NEGameService
//
//  Created by GW-He on 15/11/25.
//  Copyright © 2015年 GW-He. All rights reserved.
//

#import "UIWebView+NECache.h"

@implementation UIWebView (NECache)

- (void)cleanCache{
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    [self setDelegate:nil];
    [self removeFromSuperview];
}

@end
