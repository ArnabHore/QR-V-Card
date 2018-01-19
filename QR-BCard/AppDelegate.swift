//
//  AppDelegate.swift
//  QR-BCard
//
//  Created by Arnab Hore on 02/07/17.
//  Copyright © 2017 Arnab Hore. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
            
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 255/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0), NSFontAttributeName: UIFont.init(name: "BrandonGrotesque-Bold", size: 10.0)!], for:.selected)
            
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0), NSFontAttributeName: UIFont.init(name: "BrandonGrotesque-Bold", size: 10.0)!], for:.normal)

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
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
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

