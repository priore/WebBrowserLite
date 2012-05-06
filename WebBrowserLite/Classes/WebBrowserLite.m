//
//  WebBrowserLite.m
//
//  Created by Danilo Priore on 21/04/12.
//  Copyright (c) 2012 Prioregroup.com. All rights reserved.
//

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//
#ifndef WEBBROWSERLITE_CLASS
#define WEBBROWSERLITE_CLASS

#define BUTTON_MARGIN   5.0f
#define BUTTON_SIZE     CGSizeMake(30, 30)

#import <QuartzCore/QuartzCore.h>
#import "WebBrowserLite.h"

@interface WebBrowserLite() <UIWebViewDelegate>
{
    UIWebView *webView;
    
    UIImageView *lockView;
    
    UIButton *backButton;
    UIButton *forwardButton;
    
    UIView *activity;
    UIActivityIndicatorView *spinner;
}

- (void)hideToLeft:(BOOL)toLeft hidden:(BOOL)hidden view:(UIView*)view;
- (void)hideActivityIndicator:(BOOL)hidden;
- (UIViewController *)getCurrentRootViewController;

@end

@implementation WebBrowserLite

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super init]) {
        self.view.frame = frame;
    }
    
    return self;
}

- (id)initWithURL:(NSURL*)url {
    
    if (self = [self init]) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self loadURL:url];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    CGRect frame = self.view.frame;
    self.view.autoresizesSubviews = YES;
    self.view.contentMode = UIViewContentModeRedraw;
    self.view.backgroundColor = [UIColor clearColor];
    
    // webview full view
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    // close button on top right
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(frame.size.width - BUTTON_SIZE.width - BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_SIZE.width, BUTTON_SIZE.height);
    closeButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.7];
    closeButton.showsTouchWhenHighlighted = YES;
    closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    closeButton.layer.borderWidth = 1;
    closeButton.layer.cornerRadius = 10;
    closeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    closeButton.layer.shadowOpacity = 0.5;
    closeButton.layer.shadowOffset = CGSizeMake(0, -1);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [closeButton setImage:[UIImage imageNamed:@"WebBrowserLite.bundle/close.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // lock image for https pages (initial out of view)
    lockView = [[UIImageView alloc] initWithFrame:CGRectMake(-BUTTON_SIZE.width, BUTTON_MARGIN, BUTTON_SIZE.width, BUTTON_SIZE.height)];
    lockView.contentMode = UIViewContentModeCenter;
    lockView.image = [UIImage imageNamed:@"WebBrowserLite.bundle/lock.png"];
    lockView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.7];
    lockView.layer.borderColor = [UIColor whiteColor].CGColor;
    lockView.layer.borderWidth = 1;
    lockView.layer.cornerRadius = 10;
    lockView.layer.shadowColor = [UIColor blackColor].CGColor;
    lockView.layer.shadowOpacity = 0.5;
    lockView.layer.shadowOffset = CGSizeMake(0, -1);
    lockView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:lockView];
    
    // back button on bottom left (initial out of view)
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(-BUTTON_SIZE.width, frame.size.height - BUTTON_SIZE.height - BUTTON_MARGIN, BUTTON_SIZE.width, BUTTON_SIZE.height);
    backButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.7];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    backButton.layer.borderWidth = 1;
    backButton.layer.cornerRadius = 10;
    backButton.layer.shadowColor = [UIColor blackColor].CGColor;
    backButton.layer.shadowOpacity = 0.5;
    backButton.layer.shadowOffset = CGSizeMake(0, -1);
    backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [backButton setImage:[UIImage imageNamed:@"WebBrowserLite.bundle/arrow-left.png"] forState:UIControlStateNormal];
    [backButton addTarget:webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // forward button on bottom right (initial out of view)
    forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(frame.size.width, backButton.frame.origin.y, BUTTON_SIZE.width, BUTTON_SIZE.height);
    forwardButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.7];
    forwardButton.showsTouchWhenHighlighted = YES;
    forwardButton.layer.borderColor = [UIColor whiteColor].CGColor;
    forwardButton.layer.borderWidth = 1;
    forwardButton.layer.cornerRadius = 10;
    forwardButton.layer.shadowColor = [UIColor blackColor].CGColor;
    forwardButton.layer.shadowOpacity = 0.5;
    forwardButton.layer.shadowOffset = CGSizeMake(0, -1);
    forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [forwardButton setImage:[UIImage imageNamed:@"WebBrowserLite.bundle/arrow-right.png"] forState:UIControlStateNormal];
    [forwardButton addTarget:webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forwardButton];
    
    // activity indicator container (initial hidden)
    activity = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    activity.alpha = 0;
    activity.opaque = NO;
    activity.layer.cornerRadius = 10;		
    activity.autoresizesSubviews = YES;
    activity.userInteractionEnabled = NO;
    activity.layer.shadowColor = [UIColor blackColor].CGColor;
    activity.layer.shadowOpacity = 0.5;
    activity.layer.shadowOffset = CGSizeMake(0, -1);
    activity.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    activity.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.7];
    activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;		
    [self.view addSubview:activity];
    
    // activity indicator
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(activity.frame.size.width / 2, activity.frame.size.height / 2);
    [activity addSubview:spinner];

}

- (void)show {
    // show view
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    UIViewController *root = [self getCurrentRootViewController];
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:root.view
							 cache:YES];
	[root.view addSubview:self.view];
	[UIView commitAnimations];
}

- (void)hide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    // generate the delegate and check if stop default animation
    if (delegate != nil && [delegate respondsToSelector:@selector(webBrowserLite:viewDidClose:)]) {
        BOOL ret = [delegate webBrowserLite:self viewDidClose:self];
        if (!ret) return;
    }
    
    UIViewController *root = [self getCurrentRootViewController];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:root.view
							 cache:YES];
	[self.view removeFromSuperview];
	[UIView commitAnimations];
}

- (void)loadURL:(NSURL *)url {
    // start navigation
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)hideToLeft:(BOOL)toLeft hidden:(BOOL)hidden view:(UIView*)view {
    
    // show/hide back button with animation
    BOOL visible = CGRectContainsPoint(self.view.bounds, view.frame.origin);
    if (visible && hidden) {
        // hide to left
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        CGFloat x = toLeft ? -BUTTON_SIZE.width - BUTTON_MARGIN : BUTTON_SIZE.width + BUTTON_MARGIN;
        view.transform = CGAffineTransformMakeTranslation(x,  0);
        [UIView commitAnimations];
    } else if (!visible && !hidden) {
        // show from left
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        CGFloat x = toLeft ? BUTTON_SIZE.width + BUTTON_MARGIN : -BUTTON_SIZE.width - BUTTON_MARGIN;
        view.transform = CGAffineTransformMakeTranslation(x, 0);
        [UIView commitAnimations];
    }
}

- (void)hideActivityIndicator:(BOOL)hidden {
    // show/hide activity indicator
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideActivityIndicator) object:nil];
    
    [spinner startAnimating];
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.1];
    
    if (hidden) {
        // stop spinner after end animation
        [UIView setAnimationDelegate:spinner];
        [UIView setAnimationDidStopSelector:@selector(stopAnimating)];
    }
	
	activity.alpha = hidden ? 0 : 1;
	[UIView commitAnimations];
}

- (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result = nil;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];	
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    
    else
        NSAssert(NO, @"WebBrowserLite: Could not find a root view controller.");
    
    return result;    
}

#pragma mark - WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    [self hideActivityIndicator:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [self hideActivityIndicator:YES];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [self hideActivityIndicator:YES];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // show/hide back/forward buttons
    [self hideToLeft:YES hidden:!aWebView.canGoBack view:backButton];
    [self hideToLeft:NO hidden:!aWebView.canGoForward view:forwardButton];
    
    // show/hide lock image for secure pages
    NSURL *url = request.URL;
    [self hideToLeft:YES hidden:![url.scheme isEqual:@"https"] view:lockView];
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // support full device orientation
    return YES;
}

- (void)dealloc {
    
    [webView release];
    [lockView release];
    [backButton release];
    [forwardButton release];
    [activity release];
    [spinner release];
    [super dealloc];
}

@end

#endif
