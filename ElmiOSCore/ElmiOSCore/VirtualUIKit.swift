import UIKit
import YogaKit
import JavaScriptCore


class VirtualUIKit : NSObject {
    
    typealias Json = [String : Any]

    static var rootView : UIView? = nil
    static let viewController : ViewController = {
        let window = UIApplication.shared.keyWindow!
        let navigationController = window.rootViewController as! UINavigationController
        return navigationController.viewControllers.first as! ViewController
    }()


    /* APPLY PATCHES */
    

    static func applyPatches(_ patches: inout Json) {
        print("applyPatches")
        if let root = rootView {
            addUIKitNodes(view: root, patch: &patches)
            applyPatchesHelp(patches)
            root.yoga.applyLayout(preservingOrigin: true)
        }
    }
    
    static func applyPatchesHelp(_ patch: Json) {
        if let ctor = patch["ctor"] as? String {
            switch ctor {
            case "change":
                applyPatch(patch)
                break
            case "at":
                if let subpatch = patch["patch"] as? Json {
                    applyPatchesHelp(subpatch)
                }
                break
            case "batch":
                if let patches = patch["patches"] as? [Json] {
                    for p in patches {
                        applyPatchesHelp(p)
                    }
                }
                break
            default:
                break
            }
        }
    }

    static func applyPatch(_ patch: Json) {
        if let type = patch["type"] as? String, let node = patch["node"] as? UIView {
            switch type {
            case "redraw":
                if let virtualNode = patch["data"] as? Json, let newNode = render(virtualView: virtualNode) {
                    if let parent = node.superview {
                        replaceSubview(parent: parent, old: node, new: newNode)
//                        parent.yoga.applyLayout(preservingOrigin: true)
                    }
                }
            case "facts":
                if let facts = patch["data"] as? Json, let tag = facts["tag"] as? String {
                    applyFacts(view: node, facts: facts, tag: tag)
                }
            case "append":
                if let children = patch["data"] as? [Json] {
                    for virtualChild in children {
                        if let child = render(virtualView: virtualChild) {
                            node.addSubview(child)
                        }
                    }
                }
            case "remove-last":
                if var amount = patch["data"] as? Int {
                    let subviews : [UIView] = node.subviews
                    let subviewsLength = subviews.count
                    amount = min(amount, subviewsLength)
                    while amount > 0 {
                        subviews[subviewsLength - amount].removeFromSuperview()
                        amount -= 1;
                    }
                }
            default:
                return
            }
        }
    }

    static func replaceSubview(parent: UIView, old: UIView, new: UIView) {
        parent.insertSubview(new, belowSubview: old)
        old.removeFromSuperview()
    }



    /* ADD UIKIT NODES TO PATCHES */

    static func addUIKitNodes(view: UIView, patch: inout Json) {
        if let ctor = patch["ctor"] as? String {
            switch ctor {
            case "change":
                patch["node"] = view
                break
            case "at":
                if let index = patch["index"] as? Int, var subpatch = patch["patch"] as? Json {
                    addUIKitNodes(view: view.subviews[index], patch: &subpatch)
                    patch["patch"] = subpatch
                }
                break
            case "batch":
                if var patches = patch["patches"] as? [Json] {
                    for i in 0..<patches.count {
                        addUIKitNodes(view: view, patch: &patches[i])
                    }
                    patch["patches"] = patches
                }
                break
            default:
                break
            }
        }
    }



    /* RENDER */


    static func initialRender(view: Json, eventTree: Json) {
        print("initialRender")
        var offset = 0
        if let renderedView = render(virtualView: view, eventOffset: &offset, eventNode: eventTree) {
            rootView = renderedView
            viewController.addToRootView(subview: renderedView)
        }
    }

    static func render(virtualView: Json, eventOffset: inout Int, eventNode: Json) -> UIView? {
        if let type = virtualView["type"] as? String {
            switch type {
            case "thunk":
                if let node = virtualView["node"] as? Json {
                    return render(virtualView: node, eventOffset: &eventOffset, eventNode: eventNode)
                }
            case "tagger":
                if let node = virtualView["node"] as? Json {
                    var newEventNode = eventNode["kidListHd"]
                    while let evtNode = newEventNode as? Json, let offset = evtNode["offset"] as? Int, offset != eventOffset {
                        newEventNode = evtNode["next"]
                    }
                    
                    if let newEventNode = newEventNode as? Json {
                        var offset = 0
                        return render(virtualView: node, eventOffset: &offset, eventNode: newEventNode)
                    }
                }
            case "parent":
                if let facts = virtualView["facts"] as? Json, let children = virtualView["children"] as? [Json] {
                    let view: UIView = UIView()

                    applyFacts(view: view, facts: facts, tag: "parent")

                    if let handlerHead = eventNode["handlerListHd"] as? Json, let handlers = findHandlers(handlerList: handlerHead, offset: eventOffset) {
                        applyHandlers(handlers, view: view)
                    }

                    for child in children {
                        eventOffset += 1
                        if let renderedChild = render(virtualView: child, eventOffset: &eventOffset, eventNode: eventNode) {
                            view.addSubview(renderedChild)
                        }
                    }

                    return view
                }
            case "leaf":
                if let tag = virtualView["tag"] as? String, let facts = virtualView["facts"] as? Json {
                    switch tag {
                    case "label":
                        let label: UILabel = UILabel()
                        
                        applyFacts(view: label, facts: facts, tag: "label")
                        
                        if let handlerHead = eventNode["handlerListHd"] as? Json, let handlers = findHandlers(handlerList: handlerHead, offset: eventOffset) {
                            applyHandlers(handlers, view: label)
                        }

                        return label
                    default:
                        return nil
                    }
                }
            default:
                return nil
            }
        }
        return nil
    }

    
    /* APPLY HANDLERS */
    
    static func findHandlers(handlerList: Json?, offset: Int) -> [String: JSValue]? {
        var handlerNode: Any? = handlerList
        while let node = handlerNode as? Json, let handlerOffset = node["offset"] as? Int {
            if handlerOffset == offset, let handlers = node["funcs"] as? [String: JSValue] {
                return handlers
            }
                // TODO make sure the invariant of increasing offsets holds
                //                                else if handlerOffset < eventOffset {
                //                                    return
                //                                }
            handlerNode = node["next"]
        }
    }

    static func applyHandlers(_ handlers: [String: JSValue], view: UIView) {
        for (name, handler) in handlers {
            switch name {
            case "valueChanged":
                view.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
                break
            case "touchUp":
                view.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
                break
            case "touchUpOutside":
                view.addTarget(self, action: #selector(onTouchUpOutside), for: .touchUpOutside)
                break
            case "touchDown":
                view.addTarget(self, action: #selector(onTouchDown), for: .touchDownInside)
                break
            case "touchDownOutside":
                view.addTarget(self, action: #selector(onTouchDownOutside), for: .touchDownOutside)
                break
            default:
                break
            }
        }
    }

    /* APPLY FACTS */

    static func applyFacts(view: UIView, facts: Json, tag: String) {
        print("applyFacts")
        switch tag {
        case "label":
            applyLabelFacts(label: view as! UILabel, facts: facts)
            break
        case "parent":
            applyViewFacts(view: view, facts: facts)
            break
        default:
            break
        }

        if let yogaFacts = facts["YOGA"] as? Json {
            applyYogaFacts(view: view, facts: yogaFacts)
        } else {
            view.yoga.isEnabled = true
        }
    }

    static func applyLabelFacts(label: UILabel, facts: Json) {
        for key in facts.keys {
            switch key {
            case "text":
                if let value = facts[key] as? String {
                    label.text = value
                } else {
                    label.text = nil
                }
                label.yoga.markDirty()
                break
            case "textColor":
                if let value = facts[key] as? [Float] {
                    label.textColor = extractColor(value)
                } else {
                    label.textColor = .black
                }
                break
            case "textAlignment":
                if let value = facts[key] as? String {
                    // TODO store textAlignment as an Int in JSON and use rawValue
                    label.textAlignment = extractTextAlignment(value)
                } else {
                    label.textAlignment = .natural // TODO prior to iOS 9.0, `left` was the default
                }
                break
            case "font":
                if let value = facts[key] as? String {
                    label.font = UIFont(name: value, size: label.font.pointSize)
                } else {
                    label.font = UIFont.systemFont(ofSize: label.font.pointSize)
                }
                break
            case "fontSize":
                if let value = facts[key] as? CGFloat {
                    label.font = label.font.withSize(value)
                } else {
                    label.font = label.font.withSize(UIFont.systemFontSize)
                }
                break
            case "numberOfLines":
                if let value = facts[key] as? Int {
                    label.numberOfLines = value
                } else {
                    label.numberOfLines = 1
                }
                break
            case "lineBreakMode":
                if let value = facts[key] as? String {
                    // TODO store lineBreakMode as an Int in JSON and use rawValue
                    label.lineBreakMode = extractLineBreakMode(value)
                } else {
                    label.lineBreakMode = .byTruncatingTail
                }
                break
            case "shadowColor":
                if let value = facts[key] as? [Float] {
                    label.shadowColor = extractColor(value)
                } else {
                    label.shadowColor = nil
                }
                break
            case "shadowOffset":
                if let value = facts[key] as? [Double] {
                    label.shadowOffset = CGSize(width: value[0], height: value[1])
                } else {
                    label.shadowOffset = CGSize(width: 0, height: -1)
                }
                break
            default:
                break
            }
        }
    }

    static func applyViewFacts(view: UIView, facts: Json) {
        for key in facts.keys {
            switch key {
            case "backgroundColor":
                if let value = facts[key] as? [Float] {
                    view.backgroundColor = extractColor(value)
                } else {
                    view.backgroundColor = nil
                }
                break
            default:
                break
            }
        }

    }

    static func applyYogaFacts(view: UIView, facts: Json) {
        view.configureLayout { (layout) in
            layout.isEnabled = true

            for key in facts.keys {
                switch key {
                // Container properties

                case "flexDirection":
                    if let value = facts[key] as? String {
                        // TODO store flexDirection as an Int in JSON and use rawValue
                        layout.flexDirection = extractFlexDirection(value)
                    }
                    break

                case "justifyContent":
                    if let value = facts[key] as? String {
                        // TODO store justifyContent as an Int in JSON and use rawValue
                        layout.justifyContent = extractJustify(value)
                    }
                    break

                case "flexWrap":
                    if let value = facts[key] as? String {
                        // TODO store flexWrap as an Int in JSON and use rawValue
                        layout.flexWrap = extractWrap(value)
                    }
                    break

                case "alignItems":
                    if let value = facts[key] as? String {
                        // TODO store alignItems as an Int in JSON and use rawValue
                        layout.alignItems = extractAlign(value) ?? .stretch
                    }
                    break

                case "alignContent":
                    if let value = facts[key] as? String {
                        // TODO store alignContent as an Int in JSON and use rawValue
                        layout.alignContent = extractAlign(value) ?? .flexStart
                    }
                    break

                case "direction":
                    if let value = facts[key] as? String {
                        layout.direction = extractTextDirection(value)
                    }


                // Other properties

                case "alignSelf":
                    if let value = facts[key] as? String, let align = extractAlign(value) {
                        // TODO store alignSelf as an Int in JSON and use rawValue
                        layout.alignSelf = align
                    }
                    break

                case "position":
                    if let value = facts[key] as? String, value != "relative" {
                        layout.position = .absolute
                    }
                    break


                // YGValue

                case "flexBasis":
                    if let value = facts[key] as? Float {
                        layout.flexBasis = YGValue(value)
                    }
                    break

                case "left":
                    if let value = facts[key] as? Float {
                        layout.left = YGValue(value)
                    } else {
                        layout.left = YGValue(Float.nan)
                    }
                    break
                case "top":
                    if let value = facts[key] as? Float {
                        layout.top = YGValue(value)
                    }
                    break
                case "right":
                    if let value = facts[key] as? Float {
                        layout.right = YGValue(value)
                    }
                    break
                case "bottom":
                    if let value = facts[key] as? Float {
                        layout.bottom = YGValue(value)
                    }
                    break
                case "start":
                    if let value = facts[key] as? Float {
                        layout.start = YGValue(value)
                    }
                    break
                case "end":
                    if let value = facts[key] as? Float {
                        layout.end = YGValue(value)
                    }
                    break

                case "minWidth":
                    if let value = facts[key] as? Float {
                        layout.minWidth = YGValue(value)
                    }
                    break
                case "minHeight":
                    if let value = facts[key] as? Float {
                        layout.minHeight = YGValue(value)
                    }
                    break
                case "maxWidth":
                    if let value = facts[key] as? Float {
                        layout.maxWidth = YGValue(value)
                    }
                    break
                case "maxHeight":
                    if let value = facts[key] as? Float {
                        layout.maxHeight = YGValue(value)
                    }
                    break

                case "width":
                    if let value = facts[key] as? Float {
                        layout.width = YGValue(value)
                    }
                    break
                case "height":
                    if let value = facts[key] as? Float {
                        layout.height = YGValue(value)
                    }
                    break

                case "margin":
                    if let value = facts[key] as? Float {
                        layout.margin = YGValue(value)
                    }
                    break
                case "marginLeft":
                    if let value = facts[key] as? Float {
                        layout.marginLeft = YGValue(value)
                    }
                    break
                case "marginTop":
                    if let value = facts[key] as? Float {
                        layout.marginTop = YGValue(value)
                    }
                    break
                case "marginRight":
                    if let value = facts[key] as? Float {
                        layout.marginRight = YGValue(value)
                    }
                    break
                case "marginBottom":
                    if let value = facts[key] as? Float {
                        layout.marginBottom = YGValue(value)
                    }
                    break
                case "marginStart":
                    if let value = facts[key] as? Float {
                        layout.marginStart = YGValue(value)
                    }
                    break
                case "marginEnd":
                    if let value = facts[key] as? Float {
                        layout.marginEnd = YGValue(value)
                    }
                    break
                case "marginVertical":
                    if let value = facts[key] as? Float {
                        layout.marginVertical = YGValue(value)
                    }
                    break
                case "marginHorizontal":
                    if let value = facts[key] as? Float {
                        layout.marginHorizontal = YGValue(value)
                    }
                    break

                case "padding":
                    if let value = facts[key] as? Float {
                        layout.padding = YGValue(value)
                    }
                    break
                case "paddingLeft":
                    if let value = facts[key] as? Float {
                        layout.paddingLeft = YGValue(value)
                    }
                    break
                case "paddingTop":
                    if let value = facts[key] as? Float {
                        layout.paddingTop = YGValue(value)
                    }
                    break
                case "paddingRight":
                    if let value = facts[key] as? Float {
                        layout.paddingRight = YGValue(value)
                    }
                    break
                case "paddingBottom":
                    if let value = facts[key] as? Float {
                        layout.paddingBottom = YGValue(value)
                    }
                    break
                case "paddingStart":
                    if let value = facts[key] as? Float {
                        layout.paddingStart = YGValue(value)
                    }
                    break
                case "paddingEnd":
                    if let value = facts[key] as? Float {
                        layout.paddingEnd = YGValue(value)
                    }
                    break
                case "paddingVertical":
                    if let value = facts[key] as? Float {
                        layout.paddingVertical = YGValue(value)
                    }
                    break
                case "paddingHorizontal":
                    if let value = facts[key] as? Float {
                        layout.paddingHorizontal = YGValue(value)
                    }
                    break


                // CGFloat

                case "flexGrow":
                    if let value = facts[key] as? Float {
//                        layout.setValue(CGFloat(value), forKey: key)
                        layout.flexGrow = CGFloat(value)
                    }
                case "flexShrink":
                    if let value = facts[key] as? Float {
                        layout.flexShrink = CGFloat(value)
                    }

                case "borderWidth":
                    if let value = facts[key] as? Float {
                        layout.borderWidth = CGFloat(value)
                    }
                case "borderLeftWidth":
                    if let value = facts[key] as? Float {
                        layout.borderLeftWidth = CGFloat(value)
                    }
                case "borderTopWidth":
                    if let value = facts[key] as? Float {
                        layout.borderTopWidth = CGFloat(value)
                    }
                case "borderRightWidth":
                    if let value = facts[key] as? Float {
                        layout.borderRightWidth = CGFloat(value)
                    }
                case "borderBottomWidth":
                    if let value = facts[key] as? Float {
                        layout.borderBottomWidth = CGFloat(value)
                    }
                case "borderStartWidth":
                    if let value = facts[key] as? Float {
                        layout.borderStartWidth = CGFloat(value)
                    }
                case "borderEndWidth":
                    if let value = facts[key] as? Float {
                        layout.borderEndWidth = CGFloat(value)
                    }

                case "aspectRatio":
                    if let value = facts[key] as? Float {
                        layout.aspectRatio = CGFloat(value)
                    }
                    break

                default:
                    break
                }
            }
        }
    }



    /* EXTRACT PROPERTY VALUES */


    static func extractTextAlignment(_ alignment: String) -> NSTextAlignment {
        switch alignment {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        case "justified":
            return .justified
        case "natural":
            return .natural
        default:
            return .left
        }
    }

    static func extractColor(_ rgba: [Float]) -> UIColor {
        return UIColor(colorLiteralRed: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }

    static func extractLineBreakMode(_ lbM: String) -> NSLineBreakMode {
        switch lbM {
        case "byWordWrapping":
            return .byWordWrapping
        case "byCharWrapping":
            return .byCharWrapping
        case "byClipping":
            return .byClipping
        case "byTruncatingHead":
            return .byTruncatingHead
        case "byTruncatingTail":
            return .byTruncatingTail
        case "byTruncatingMiddle":
            return .byTruncatingMiddle
        default:
            return .byTruncatingTail
        }
    }

    static func extractFlexDirection(_ direction: String) -> YGFlexDirection {
        switch direction {
        case "row":
            return .row
        case "colum":
            return .column
        case "rowReverse":
            return .rowReverse
        case "columnReverse":
            return .columnReverse
        default:
            return .column
        }
    }

    static func extractJustify(_ justify: String) -> YGJustify {
        switch justify {
        case "flexStart":
            return .flexStart
        case "flexEnd":
            return .flexEnd
        case "center":
            return .center
        case "spaceBetween":
            return .spaceBetween
        case "spaceAround":
            return .spaceAround
        default:
            return .flexStart
        }
    }

    static func extractWrap(_ wrap: String) -> YGWrap {
        switch wrap {
        case "noWrap":
            return .noWrap
        case "wrap":
            return .wrap
        case "wrapReverse":
            return .wrapReverse
        default:
            return .noWrap
        }
    }

    static func extractAlign(_ align: String) -> YGAlign? {
        switch align {
        case "stretch":
            return .stretch
        case "flexStart":
            return .flexStart
        case "flexEnd":
            return .flexEnd
        case "center":
            return .center
        default:
            return nil
        }
    }

    static func extractTextDirection(_ direction: String) -> YGDirection {
        switch direction {
        case "inherit":
            return .inherit
        case "LTR":
            return .LTR
        case "RTL":
            return .RTL
        default:
            return .inherit
        }
    }

}
