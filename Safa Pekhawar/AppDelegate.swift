//
//  AppDelegate.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 25/09/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//
//
//    BOOL check = [[NSUserDefaults standardUserDefaults] boolForKey:@"login_status"];
//    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
//
//    if (!check) {
//    LoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
//    [navController pushViewController:vc animated:NO];
//    }
//    else{
//    SWRevealViewController *rootController = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
//    _window.rootViewController = rootController;
//    [self.window makeKeyAndVisible];
//    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//         Override point for customization after application launch.
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let check = UserDefaults.standard.bool(forKey: "login_status")
        
        
        if check==false {
            let navController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            self.window?.rootViewController = navController
            
            let vc: RegistrationVC = storyboard.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
            navController.pushViewController(vc, animated: false)
        }
        else
        {
            let user_type: String = UserDefaults.standard.value(forKey: "user_type") as! String
            if user_type == "admin"{
                let rootVC: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController1") as! SWRevealViewController
                self.window?.rootViewController = rootVC
            }
            else{
                let rootVC: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                self.window?.rootViewController = rootVC
            }
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

