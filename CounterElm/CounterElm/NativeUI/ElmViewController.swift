import UIKit
import JavaScriptCore

@objc protocol UIViewControllerExports: JSExport
    {}

extension UIViewController: UIViewControllerExports
    {}
