//
//  AppDelegate.swift
//  PriorityDemo
//
//  Created by 전민섭 on 2017/06/22.
//  Copyright © 2017年 전민섭. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var itemArray = [ItemStruct]()
    var profileText = String()
    var profileImgaeData = NSData()
    var contectCount = 0
    
    var center = UNUserNotificationCenter.current()
    
    func saveProfileText(result: String) {
        let defaults = UserDefaults.standard
        defaults.set(profileText, forKey: "profileTextKey")
    }
    
    func readProfileText() -> String? {
        let defaults = UserDefaults.standard
        if let defaultString = defaults.string(forKey: "profileTextKey") {
            return defaultString
        } else {
            return nil
        }
    }
    
    func saveProfileImageData(result: NSData) {
        let defaults = UserDefaults.standard
        defaults.set(profileImgaeData, forKey: "profileImageDataKey")
    }
    
    func readProfileImageData() -> NSData? {
        let defaults = UserDefaults.standard
        if let defaultData = defaults.data(forKey: "profileImageDataKey") {
            return defaultData as NSData
        } else {
            return nil
        }
    }
    
    func saveContectCount(result: Int) {
        let defaults = UserDefaults.standard
        defaults.set(contectCount, forKey: "contectCount")
    }
    
    func readContectCount() -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: "contectCount")
    }
    
    func notiSet(identifier: String, hour: Int16, minute: Int16) {
        //알림을 가능하도록 설정        
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
        }
        
        let content = UNMutableNotificationContent()
        
        content.title = identifier
        content.body = NSLocalizedString("It's time to set up!", comment: "")
        content.sound = UNNotificationSound.default()
        
        var dateInfo = DateComponents()
        dateInfo.hour = Int(hour)
        dateInfo.minute = Int(minute)
        let tigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        let notiRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: tigger)
        
        center.add(notiRequest) { (error : Error?) in
            if error != nil {
            }
        }
    }
    
    func notiDelete(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.tintColor = UIColor.init(red: 63/255, green: 63/255, blue: 63/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.init(red: 63/255, green: 63/255, blue: 63/255, alpha: 1)]
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-5542661431027733~4614279817")
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
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MedaList")
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

