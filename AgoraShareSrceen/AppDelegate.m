//
//  AppDelegate.m
//  AgoraShareSrceen
//
//  Created by ZH on 2022/5/31.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) MainViewController *mainViewController ;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
        
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;
    self.mainViewController = mainVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
