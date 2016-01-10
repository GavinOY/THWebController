//
//  THWebView.h
//  THWebController
//
//  Created by 欧阳志鑫 on 16/1/9.
//  Copyright © 2016年 欧阳志鑫. All rights reserved.
//

@import UIKit;


typedef NS_ENUM(NSInteger, THWebViewNavigationType) {
    THWebViewNavigationTypeLinkClicked,
    THWebViewNavigationTypeFormSubmitted,
    THWebViewNavigationTypeBackForward,
    THWebViewNavigationTypeReload,
    THWebViewNavigationTypeFormResubmitted,
    THWebViewNavigationTypeOther
};


@class THWebView;

@protocol THWebViewDelegate <NSObject>

@optional
- (void)webViewDidStartLoad:(THWebView *)webView;
- (void)webViewDidFinishLoad:(THWebView *)webView;
- (void)webView:(THWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(THWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(THWebViewNavigationType)navigationType;

@end


typedef void(^JavaScriptCompletionBlock)(NSString *result, NSError *error);


/**
 *  Generic web view class that wraps a UIWebView or WKWebView,
 *  depending on which one is available, as its internal implementation
 */
@interface THWebView : UIView

@property (nonatomic, weak) id<THWebViewDelegate> delegate;
@property (nonatomic, readonly, weak) UIScrollView *scrollView;

/**
 * Indicates whether the instances of THWebView that are backed by WKWebView share the same process pool.
 * That's needed for sharing the cookies and cache between those instances. The default value is YES.
 * If you change this you must do so before calling any of the methods below.
 */
@property (nonatomic, assign) BOOL shareProcessPool;

/**
 * Loads the web view with content returned by an url request
 * @params request - the url request
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 * Loads the web view with content returned by an url request
 * @params request - the url request
 * @params timeOut - max time imterval to wait for the page to load
 */
- (void)loadRequest:(NSURLRequest *)request timeOut:(NSTimeInterval)timeOut;

/**
 * Loads the web view with HTML content
 * @params string - the string to use as the contents of the webpage
 * @params baseUrl - a URL that's used for resolving relative URLs within the document
 */
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

/**
 * Loads the web view with HTML content
 * @params string - the string to use as the contents of the webpage
 * @params baseUrl - a URL that's used for resolving relative URLs within the document
 * @params timeOut - max time imterval to wait for the page to load
 */
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL timeOut:(NSTimeInterval)timeOut;

/**
 * Returns the result of running a script
 * @params script - the script to run
 */
- (void)evaluateJavaScriptFromString:(NSString *)script completionBlock:(JavaScriptCompletionBlock)block;

-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;
/**
 * Stops the loading of web view
 */
- (void)stopLoading;


- (void)reload;

- (void)goBack;
- (void)goForward;

- (void) cleanWebViewCache;
@property (nonatomic, readonly) NSString* pageTitle;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, retain) NSURLRequest *request;
@property (nonatomic, strong) NSURL *loadURL;
@end

