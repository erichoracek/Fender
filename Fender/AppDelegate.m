//
//  AppDelegate.m
//  Fender
//
//  Created by Eric Horacek on 11/13/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "ScanPlateViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    self.window.rootViewController = tabBarController;

    UINavigationController *scanPlate = [[UINavigationController alloc] initWithRootViewController:[[ScanPlateViewController alloc] init]];
    [tabBarController addChildViewController:scanPlate];

    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
