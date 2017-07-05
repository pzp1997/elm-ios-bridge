//
//  AppDelegate.swift
//  ElmiOSCore
//
//  Created by Palmer Paul on 6/27/17.
//  Copyright © 2017 Palmer Paul. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            let navigationController = UINavigationController(rootViewController: ViewController())
            navigationController.navigationBar.isTranslucent = false
            
            window.rootViewController = navigationController
            window.backgroundColor = .white
            window.makeKeyAndVisible()
        }
        return true
    }

}

