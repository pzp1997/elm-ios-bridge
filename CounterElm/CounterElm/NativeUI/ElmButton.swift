import UIKit
import JavaScriptCore

@objc protocol UIButtonExports: JSExport {
    static func makeButton() -> UIButton
    static func makeButton(withType: UIButtonType) -> UIButton
    
    
    func setTitle(_ title: String?) -> ()
    func setTitleColor(_ color: UIColor?) -> ()
//    func setClickHandler(_ handler: () -> ()) -> ()
    @objc func addTarget(_ target: Any?, action: Selector, forControlEvents: UIControlEvents)
}

extension UIButton: UIButtonExports {
    static func makeButton() -> UIButton {
        return UIButton.init()
    }

    static func makeButton(withType: UIButtonType) -> UIButton {
        return UIButton.init(type: withType)
    }
    
    func setTitle(_ title: String?) {
        setTitle(title, for: .normal)
    }
    
    func setTitleColor(_ color: UIColor?) {
        setTitleColor(color, for: .normal)
    }
}
