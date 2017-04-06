//
//  AppDelegate.swift
//  RealmQnA
//
//  Created by Eunjoo on 2017. 4. 5..
//  Copyright © 2017년 Eunjoo. All rights reserved.
//

import UIKit
import RealmLoginKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if configureDefaultRealm() {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "mainViewController") as! ViewController

            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        } else {
            window?.rootViewController = UIViewController()
            window?.makeKeyAndVisible()
            logIn(animated: false)
        }
        return true
    }
    
    func logIn(animated: Bool = true) {
        let loginController = LoginViewController(style: .darkTranslucent)
        loginController.isServerURLFieldHidden = true
        loginController.isRememberAccountDetailsFieldHidden = true
        loginController.serverURL = Constants.syncAuthURL.absoluteString
        loginController.loginSuccessfulHandler = { user in
            setDefaultRealmConfiguration(with: user)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "mainViewController") as! ViewController
            
            self.window?.rootViewController = viewController
            self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
        window?.rootViewController?.present(loginController, animated: false, completion: nil)
    }
    
    func configureDefaultRealm() -> Bool {
        if let user = SyncUser.current {
            setDefaultRealmConfiguration(with: user)
            return true
        }
        return false
    }
    
    func present(error: NSError) {
        let alertController = UIAlertController(title: error.localizedDescription,
                                                message: error.localizedFailureReason ?? "",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
            self.logIn()
        })
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
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

