//
//  AppDelegate.swift
//  BasicCounterSwift
//
//  Created by Palmer Paul on 6/15/17.
//  Copyright © 2017 Palmer Paul. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    
    var window: UIWindow?
//    var testNavigationController : UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let homeViewController = UIViewController()
        homeViewController.view.backgroundColor = UIColor.red
        window!.rootViewController = homeViewController
        window!.makeKeyAndVisible()
        return true
    }
}

//        let testViewController: UIViewController = ViewController()
//        self.testNavigationController = UINavigationController()
//        if let testNavigationController = self.testNavigationController{
//            testNavigationController.delegate = self
//            testNavigationController.setNavigationBarHidden(true, animated: false)
//            testNavigationController.pushViewController(testViewController, animated: false)
//            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//            if let window = self.window {
//                window.rootViewController = testNavigationController
//                window.makeKeyAndVisible()
//            }
            
//        }
//        return true

//import Cocoa
//
//@NSApplicationMain
//class AppDelegate: NSObject, NSApplicationDelegate {
//
//    @IBOutlet weak var window: NSWindow!
//
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Insert code here to initialize your application
//    }
//
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//    }
//
//
//}
