import UIKit
import JavaScriptCore


class ElmKit {
    static func patchGlobalContext(context: JSContext) -> () {
        context.setObject(UIView.self, forKeyedSubscript: "View" as (NSCopying & NSObjectProtocol)!)
        context.setObject(UILabel.self, forKeyedSubscript: "Label" as (NSCopying & NSObjectProtocol)!)
        context.setObject(UIButton.self, forKeyedSubscript: "Button" as (NSCopying & NSObjectProtocol)!)
        context.setObject(UIColor.self, forKeyedSubscript: "Color" as (NSCopying & NSObjectProtocol)!)
        context.setObject(UIWindow.self, forKeyedSubscript: "Window" as (NSCopying & NSObjectProtocol)!)
        //    context.setObject(UIButtonType, forKeyedSubscript: "ButtonType" as (NSCopying & NSObjectProtocol)!)
        context.setObject(UIViewController.self, forKeyedSubscript: "ViewController" as (NSCopying & NSObjectProtocol)!)
        context.setObject(CGRect.self, forKeyedSubscript: "Rect" as (NSCopying & NSObjectProtocol)!)
    }
}
