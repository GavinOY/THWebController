//
//  ViewController.m
//  THWebController
//
//  Created by 欧阳志鑫 on 16/1/9.
//  Copyright © 2016年 欧阳志鑫. All rights reserved.
//

#import "THWebController.h"
#import "THWebView.h"
#import "Constant.h"
#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif


@interface THWebController()<THWebViewDelegate>
//@property (nonatomic, readwrite, NI_STRONG) UIWebView* webView;
@property (nonatomic, readwrite, NI_STRONG) UIToolbar* toolbar;
@property (nonatomic, readwrite, NI_STRONG) UIActionSheet* actionSheet;

@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* backButton;
@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* forwardButton;
@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* refreshButton;
@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* stopButton;
@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* actionButton;
@property (nonatomic, readwrite, NI_STRONG) UIBarButtonItem* activityItem;

@property (nonatomic, readwrite, NI_STRONG) NSURL* loadingURL;

@property (nonatomic, readwrite, NI_STRONG) NSURLRequest* loadRequest;
@property (nonatomic,NI_STRONG) UIView *failTipView;
@property (nonatomic,assign) BOOL isError;

@property(nonatomic,strong) THWebView *thWebView;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation THWebController

//@synthesize webView = _webView;
@synthesize toolbar = _toolbar;
@synthesize actionSheet = _actionSheet;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize stopButton = _stopButton;
@synthesize actionButton = _actionButton;
@synthesize activityItem = _activityItem;
@synthesize actionSheetURL = _actionSheetURL;
@synthesize loadingURL = _loadingURL;
@synthesize loadRequest = _loadRequest;
@synthesize toolbarHidden = _toolbarHidden;
@synthesize toolbarTintColor = _toolbarTintColor;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    _actionSheet.delegate = nil;
    _thWebView.delegate = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRequest:(NSURLRequest *)request {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.hidesBottomBarWhenPushed = YES;
        [self openRequest:request];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)URL {
    // URL = [[NSURL alloc]initWithString:@"http://www.16163.com/ldxy/10041/?app=xiaomei"];
    // return [self initWithRequest:[NSURLRequest requestWithURL:URL]];
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.hidesBottomBarWhenPushed = YES;
        [self openURL:URL];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRequest:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapBackButton {
    [self.thWebView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapForwardButton {
    [self.thWebView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapRefreshButton {
    //[self.thWebView reload];
    self.isError = NO;
    [self.thWebView loadRequest:self.loadRequest];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapStopButton {
    [self.thWebView stopLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapShareButton {
    // Dismiss the action menu if the user taps the action button again on the iPad.
    if ([self.actionSheet isVisible]) {
        // It shouldn't be possible to tap the share action button again on anything but the iPad.
        NSParameterAssert(NIIsPad());
        
        [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:YES];
        
        // We remove the action sheet here just in case the delegate isn't properly implemented.
        self.actionSheet.delegate = nil;
        self.actionSheet = nil;
        self.actionSheetURL = nil;
        
        // Don't show the menu again.
        return;
    }
    
    // Remember the URL at this point
    self.actionSheetURL = [self.URL copy];
    
    if (nil == self.actionSheet) {
        self.actionSheet =
        [[UIActionSheet alloc] initWithTitle:[self.actionSheetURL absoluteString]
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        // Let -shouldPresentActionSheet: setup the action sheet
        if (![self shouldPresentActionSheet:self.actionSheet]) {
            // A subclass decided to handle the action in another way
            self.actionSheet = nil;
            self.actionSheetURL = nil;
            return;
        }
        // Add "Cancel" button except for iPads
        if (!NIIsPad()) {
            [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")]];
        }
    }
    
    if (NIIsPad()) {
        [self.actionSheet showFromBarButtonItem:self.actionButton animated:YES];
    } else {
        [self.actionSheet showInView:self.view];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!self.toolbarHidden) {
        CGRect toolbarFrame = self.toolbar.frame;
        toolbarFrame.size.height = NIToolbarHeightForOrientation(interfaceOrientation);
        toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
        self.toolbar.frame = toolbarFrame;
        
        CGRect webViewFrame = self.thWebView.frame;
        webViewFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
        self.thWebView.frame = webViewFrame;
        
    } else {
        self.thWebView.frame = self.view.bounds;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWebViewFrame {
    if (self.toolbarHidden) {
        self.thWebView.frame = self.view.bounds;
        
    } else {
        self.thWebView.frame = NIRectContract(self.view.bounds, 0, self.toolbar.frame.size.height);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    CGRect bounds = self.view.bounds;
    CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
    CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                     bounds.size.width, toolbarHeight);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                     | UIViewAutoresizingFlexibleWidth);
    self.toolbar.tintColor = self.toolbarTintColor;
    self.toolbar.hidden = self.toolbarHidden;
    
    UIActivityIndicatorView* spinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
     UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    UIImage* backIcon = [UIImage imageWithContentsOfFile:
                         NIPathForBundleResource(nil, @"THWebController.bundle/gfx/backIcon.png")];
    // We weren't able to find the forward or back icons in your application's resources.
    // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
    //into your application with the "Create Folder References" option selected. You can verify that
    // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
    // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
    // copied in the Copy Bundle Resources phase.
    NSParameterAssert(nil != backIcon);
    
    self.backButton =
    [[UIBarButtonItem alloc] initWithImage:backIcon
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapBackButton)];
    self.backButton.tag = 2;
    self.backButton.enabled = NO;
    
    UIImage* forwardIcon = [UIImage imageWithContentsOfFile:
                            NIPathForBundleResource(nil, @"THWebController.bundle/gfx/forwardIcon.png")];
    // We weren't able to find the forward or back icons in your application's resources.
    // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
    // into your application with the "Create Folder References" option selected. You can verify that
    // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
    // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
    // copied in the Copy Bundle Resources phase.
    NSParameterAssert(nil != forwardIcon);
    
    self.forwardButton =
    [[UIBarButtonItem alloc] initWithImage:forwardIcon
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapForwardButton)];
    self.forwardButton.tag = 1;
    self.forwardButton.enabled = NO;
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                          UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefreshButton)];
    self.refreshButton.tag = 3;
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                       UIBarButtonSystemItemStop target:self action:@selector(didTapStopButton)];
    self.stopButton.tag = 3;
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemAction target:self action:@selector(didTapShareButton)];
    
    UIBarItem* flexibleSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                  target: nil
                                                  action: nil];
    
    self.toolbar.items = [NSArray arrayWithObjects:
                          self.backButton,
                          flexibleSpace,
                          self.forwardButton,
                          flexibleSpace,
                          self.refreshButton,
                          flexibleSpace,
                          self.actionButton,
                          nil];
    [self.view addSubview:self.toolbar];
    
    self.thWebView = [[THWebView alloc] initWithFrame:CGRectZero];
    [self updateWebViewFrame];
    self.thWebView.delegate = self;
    self.thWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                       | UIViewAutoresizingFlexibleHeight);
    //self.webView.scalesPageToFit = YES;
    
    [self.view addSubview:self.thWebView];
    
    //加载失败显示的图片
    CGRect webViewFrame = self.thWebView.frame;
    CGRect hindViewFrame= CGRectMake(webViewFrame.origin.x, webViewFrame.origin.y, webViewFrame.size.width,bounds.size.height);
    _failTipView = [[UIView alloc]initWithFrame:hindViewFrame];
    [self setFailView:_failTipView];
    _failTipView.hidden = YES;
    _failTipView.backgroundColor = [UIColor whiteColor];
    [self.thWebView addSubview:_failTipView];
    
    if (nil != self.loadRequest) {
        [self.thWebView loadRequest:self.loadRequest];
    }
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.actionSheet.delegate = nil;
    self.thWebView.delegate = nil;
    
    self.actionSheet = nil;
    self.thWebView = nil;
    self.toolbar = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.refreshButton = nil;
    self.stopButton = nil;
    self.actionButton = nil;
    self.activityItem = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateToolbarWithOrientation:self.interfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
    // If the browser launched the media player, it steals the key window and never gives it
    // back, so this is a way to try and fix that.
    //[self.view.window makeKeyWindow];
    
    [super viewWillDisappear:animated];
    //[self.webView cleanCache];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.view.window makeKeyWindow];
    [super viewDidDisappear:animated];
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[THWebController class]]) {
            return;
        }
    }
    [self.thWebView cleanWebViewCache];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (NIIsPad()) {
        return YES;
    } else {
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return YES;
            default:
                return NO;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateToolbarWithOrientation:toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - thWebViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(THWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(THWebViewNavigationType)navigationType {
    self.loadingURL = [request.mainDocumentURL copy];
    self.backButton.enabled = [self.thWebView canGoBack];
    self.forwardButton.enabled = [self.thWebView canGoForward];
    
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(THWebView*)webView {
    self.title = NSLocalizedString(@"加载中...", @"");
    if (!self.navigationItem.rightBarButtonItem) {
        [self.navigationItem setRightBarButtonItem:self.activityItem animated:YES];
    }
    
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in self.toolbar.items) {
        if (button.tag == 3) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
            [newItems replaceObjectAtIndex:buttonIndex withObject:self.stopButton];
            self.toolbar.items = newItems;
            break;
        }
        ++buttonIndex;
    }
    self.backButton.enabled = [self.thWebView canGoBack];
    self.forwardButton.enabled = [self.thWebView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(THWebView*)webView {
    
    if (!_specificTitleText) {
        self.title = [self.thWebView pageTitle];
    }else{
        self.title = _specificTitleText;
    }
    
    if (self.navigationItem.rightBarButtonItem == self.activityItem) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in self.toolbar.items) {
        if (button.tag == 3) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
            [newItems replaceObjectAtIndex:buttonIndex withObject:self.refreshButton];
            self.toolbar.items = newItems;
            break;
        }
        ++buttonIndex;
    }
    
    self.backButton.enabled = [self.thWebView canGoBack];
    self.forwardButton.enabled = [self.thWebView canGoForward];
    
    NSCachedURLResponse *cachedResp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)cachedResp.response;
    if (404 == resp.statusCode|| 403 == resp.statusCode||500 == resp.statusCode) {
        self.isError = YES;
    }
    
    if (self.isError) {
        _failTipView.hidden = NO;
        self.toolbar.hidden = YES;
        self.title=@"打开失败";
    }else{
        _failTipView.hidden = YES;
        self.toolbar.hidden = NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(THWebView*)webView didFailLoadWithError:(NSError*)error {
    NSLog(@"%@, %ld", error.domain, (long)error.code);
    //    if (error.domain == NSURLErrorDomain) {
    //
    //        if (error.code == NSURLErrorCancelled) { //ignore this one, interrupted load
    //            return;
    //        }
    //    }else if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 204){
    //        return;
    //    }
    //    else if([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102){
    //        //"帧框加载已中断" 有些是打不开
    //        return;
    //    }
    
    self.isError = YES;
    
    [self.thWebView.delegate webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:self.actionSheetURL];
        } else if (buttonIndex == 1) {
            [[UIPasteboard generalPasteboard] setURL:self.actionSheetURL];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        self.actionSheet.delegate = nil;
        self.actionSheet = nil;
        self.actionSheetURL = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)URL {
    return self.loadingURL ? self.loadingURL : self.thWebView.request.mainDocumentURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
    self.loadingURL = URL;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.loadingURL];
    [self openRequest:request];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest *)request {
    self.loadRequest = request;
    
    if ([self isViewLoaded]) {
        if (nil != request) {
            [self.thWebView loadRequest:request];
            
        } else {
            [self.thWebView stopLoading];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openHTMLString:(NSString*)htmlString baseURL:(NSURL*)baseUrl {
    NSParameterAssert([self isViewLoaded]);
    [_thWebView loadHTMLString:htmlString baseURL:baseUrl];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarHidden:(BOOL)hidden {
    _toolbarHidden = hidden;
    if ([self isViewLoaded]) {
        self.toolbar.hidden = hidden;
        [self updateWebViewFrame];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarTintColor:(UIColor*)color {
    if (color != _toolbarTintColor) {
        _toolbarTintColor = color;
    }
    
    if ([self isViewLoaded]) {
        self.toolbar.tintColor = color;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet {
    if (actionSheet == self.actionSheet) {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"在Safari中打开", @"")];
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"复制链接到粘贴板", @"")];
    }
    return YES;
}

- (void)setFailView:(UIView*)view
{
    UIImageView *failImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading_fail"]];
    failImage.frame = CGRectMake(0, 0, 100, 100);
    failImage.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-64);
    [view addSubview:failImage];
    
    CGFloat offY = failImage.frame.origin.y+ failImage.frame.size.height + 15;
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.text = @"打开链接失败，试试用浏览器打开吧";
    tipLabel.font = [UIFont systemFontOfSize:fontSize];
    tipLabel.textColor = UIColorFromRGB(0x999999);
    NSAttributedString *attributedText =
    [[NSAttributedString alloc] initWithString:tipLabel.text attributes:@{NSFontAttributeName: tipLabel.font}];
    CGSize tipLabelSize = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    tipLabel.frame = CGRectMake(0, 0, tipLabelSize.width, tipLabelSize.height);
    tipLabel.center = CGPointMake(self.view.frame.size.width/2, offY+tipLabelSize.height/2);
    [view addSubview:tipLabel];
    
    offY = tipLabel.frame.origin.y+ tipLabel.frame.size.height + 15;
    UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, 0, 100, 35);
    btn.center = CGPointMake(self.view.frame.size.width/2, offY+35/2);
    [btn setTitle:@"浏览器打开" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [btn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [btn.layer setBorderWidth:0.5]; //边框宽度
    [btn.layer setBorderColor:UIColorFromRGB(0x666666).CGColor];//边
    [view addSubview:btn];
    
    [btn addTarget:self action:@selector(openSafari:) forControlEvents:UIControlEventTouchUpInside];
    
}

//打开浏览器
- (void)openSafari:(UIButton*)btn
{
    self.loadingURL = self.thWebView.loadURL;
    if (!self.loadingURL) {
        return;
    }
    
    btn.backgroundColor =[UIColor clearColor];
    [[UIApplication sharedApplication] openURL:self.loadingURL];
}

@end

