//
//  AppDelegate.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.systemBackground
        
        if let window = window {
            window.rootViewController = RootViewController()
            window.makeKeyAndVisible()
        }
        
        return true
    }
}

