import UIKit
import JavaScriptCore

@objc protocol UILabelExports: JSExport {
    static func makeLabel() -> UILabel
    static func makeLabel(withFrame: CGRect) -> UILabel
    
    @objc var text: String? { get set }
    @objc var font: UIFont! { get set }
    @objc var textColor: UIColor! { get set }

    func textAlignmentLeft() -> ()
    func textAlignmentRight() -> ()
    func textAlignmentCenter() -> ()
    func textAlignmentJustifed() -> ()
    func textAlignmentNatural() -> ()
}

extension UILabel: UILabelExports {
    static func makeLabel() -> UILabel {
        return UILabel()
    }
    
    static func makeLabel(withFrame: CGRect) -> UILabel {
        return UILabel(frame: withFrame)
    }
    
    
    func textAlignmentLeft() -> () {
        textAlignment = .left
    }

    func textAlignmentRight() -> () {
        textAlignment = .right
    }

    func textAlignmentCenter() -> () {
        textAlignment = .center
    }

    func textAlignmentJustifed() -> () {
        textAlignment = .justified
    }

    func textAlignmentNatural() -> () {
        textAlignment = .natural
    }
}

