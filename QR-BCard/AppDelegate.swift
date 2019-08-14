//
//  AppDelegate.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        UIApplication.shared.statusBarStyle = .lightContent

        let tabbarController: UITabBarController = self.window?.rootViewController as! UITabBarController
        if tabbarController.isKind(of: UITabBarController.self) {
            tabbarController.selectedIndex = 2
            
            let tabbarItem1: UITabBarItem = tabbarController.tabBar.items![0]
            let tabbarItem2: UITabBarItem = tabbarController.tabBar.items![1]
            let tabbarItem3: UITabBarItem = tabbarController.tabBar.items![2]

            tabbarItem1.image = UIImage(named: "list_grey.png")?.withRenderingMode(.alwaysOriginal)
            tabbarItem2.image = UIImage(named: "qr_grey.png")?.withRenderingMode(.alwaysOriginal)
            tabbarItem3.image = UIImage(named: "me_grey.png")?.withRenderingMode(.alwaysOriginal)
            
            tabbarItem1.selectedImage = UIImage(named: "list.png")?.withRenderingMode(.alwaysOriginal)
            tabbarItem2.selectedImage = UIImage(named: "qr.png")?.withRenderingMode(.alwaysOriginal)
            tabbarItem3.selectedImage = UIImage(named: "me.png")?.withRenderingMode(.alwaysOriginal)
            
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(red: 255/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0), NSAttributedString.Key.font: UIFont.init(name: "BrandonGrotesque-Bold", size: 10.0)!], for:.selected)
            
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(red: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0), NSAttributedString.Key.font: UIFont.init(name: "BrandonGrotesque-Bold", size: 10.0)!], for:.normal)

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
        self.askToRate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }
    
    internal func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        print(userActivity.activityType)
//        guard userActivity.activityType == NSStringFromClass(OrderSoupIntent.self) ||
//            userActivity.activityType == NSUserActivity.viewMenuActivityType ||
//            userActivity.activityType == NSUserActivity.orderCompleteActivityType else {
//                os_log("Can't continue unknown NSUserActivity type %@", userActivity.activityType)
//                return false
//        }
//
//        guard let window = window,
//            let rootViewController = window.rootViewController as? UINavigationController else {
//                os_log("Failed to access root view controller.")
//                return false
//        }
        
        // The `restorationHandler` passes the user activity to the passed in view controllers to route the user to the part of the app
        // that is able to continue the specific activity. See `restoreUserActivityState` in `OrderHistoryTableViewController`
        // to follow the continuation of the activity further.
//        restorationHandler(rootViewController.viewControllers)
        return true
    }

    // MARK: - Rating

    func askToRate() {
        var appSessions = UserDefaults.standard.integer(forKey: "appSessions")
        print(appSessions)
        if appSessions % 10 == 0 && appSessions != 0 && appSessions <= 30 {
            let shortestTime: UInt32 = 20
            let longestTime: UInt32 = 40
            if let timeInterval = TimeInterval(exactly: arc4random_uniform(longestTime - shortestTime) + shortestTime) {
                Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.requestReview), userInfo: nil, repeats: false)
            }
        }
        appSessions += 1
        UserDefaults.standard.set(appSessions, forKey: "appSessions")
        
        var userID = ""
        if let uid = UserDefaults.standard.value(forKey: "userID") as? String, uid.count > 0 {
            userID = uid
        } else {
            userID = "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))_\(arc4random_uniform(100))"
            UserDefaults.standard.set(userID, forKey: "userID")
            UserDefaults.standard.synchronize()
        }
        print(userID)
        Analytics.logEvent("app_sessions", parameters: ["user_id" : userID, "count" : appSessions])
    }
    
    @objc func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "QR_BCard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

