//
//  AppDelegate.swift
//  Demo
//
//  Created by bob on 2020/2/23.
//  Copyright © 2020 dwb. All rights reserved.
//

import UIKit
import RangersAppLog


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        self.window = window
        
        
        let nav = UINavigationController(rootViewController: ViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (BDAutoTrackSchemeHandler.shared().handle(url, appID: "123", scene: nil)) {
            return true
        }
        
        return false
    }

}

