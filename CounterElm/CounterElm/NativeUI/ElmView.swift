import UIKit
import YogaKit
import JavaScriptCore

@objc protocol UIViewExports: JSExport {
    static func makeView() -> UIView
    static func makeView(withFrame: CGRect) -> UIView
    
    @objc var bounds: CGRect { get set }
    @objc var backgroundColor: UIColor? { get set }
    
    @objc func addSubview(_ view: UIView) -> ()
    
//    func configureLayout(_ block: YGLayoutConfigurationBlock)
}

extension UIView: UIViewExports {
    static func makeView() -> UIView {
        return UIView()
    }
    
    static func makeView(withFrame: CGRect) -> UIView {
        return UIView(frame: withFrame)
    }
}
