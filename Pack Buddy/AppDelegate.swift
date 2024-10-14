//
//  AppDelegate.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 18/09/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register custom UIColor transformer for Core Data
        ValueTransformer.setValueTransformer(UIColorTransformer(), forName: NSValueTransformerName("UIColorTransformer"))
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

