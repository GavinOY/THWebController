//
//  ViewController.m
//  THWebController
//
//  Created by 欧阳志鑫 on 16/1/9.
//  Copyright © 2016年 欧阳志鑫. All rights reserved.
//

#import "ViewController.h"
#import "THWebController.h"
@interface ViewController ()
@property (nonatomic, weak) UINavigationController *webControlWrapperNavigation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)openWebView:(id)sender {
    NSURL *url =[NSURL URLWithString:@"https://www.baidu.com"];
    THWebController *webController = [[THWebController alloc] initWithURL:url];
    webController.automaticallyAdjustsScrollViewInsets = NO;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:webController];
    navigation.navigationBar.translucent = NO;
    self.webControlWrapperNavigation = navigation;
    [self presentViewController:navigation animated:YES completion:^{
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        UIImage *backButtonImage= [UIImage imageNamed:@"btn_close"];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(didClickWebControlCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        webController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }];

}

- (void)didClickWebControlCloseBtn {
    [self.webControlWrapperNavigation dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
