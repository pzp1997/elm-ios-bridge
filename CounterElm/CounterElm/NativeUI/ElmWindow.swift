import UIKit
import JavaScriptCore

@objc protocol UIWindowExports: JSExport {
    static func makeWindow() -> UIWindow
    static func makeWindow(withFrame: CGRect) -> UIWindow
    
    @objc var rootViewController: UIViewController? { get set }
    
    @objc func makeKeyAndVisible() -> ()
}

extension UIWindow: UIWindowExports {
    static func makeWindow() -> UIWindow {
        return UIWindow()
    }

    static func makeWindow(withFrame: CGRect) -> UIWindow {
        return UIWindow(frame: withFrame)
    }
}
