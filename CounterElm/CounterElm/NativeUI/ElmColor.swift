import UIKit
import JavaScriptCore

@objc protocol UIColorExports: JSExport {
    @objc static var blackColor: UIColor { get }
    @objc static var greenColor: UIColor { get }
    @objc static var redColor: UIColor { get }
    @objc static var whiteColor: UIColor { get }
}

extension UIColor: UIColorExports
    {}
