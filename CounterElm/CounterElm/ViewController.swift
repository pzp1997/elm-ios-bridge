import UIKit
import JavaScriptCore

extension String: Error {}

fileprivate extension Selector {
    static let incrementAction =
        #selector(ViewController.incrementAction)
    static let decrementAction =
        #selector(ViewController.decrementAction)
}


class ViewController: UIViewController {
    
    var context: JSContext? = {
        let context: JSContext! = JSContext()
        
        ElmKit.patchGlobalContext(context: context)
        
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("console.log: " + message)
        }
        context?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "_consoleLog" as (NSCopying & NSObjectProtocol)!)
        
        guard let appJsPath = Bundle.main.path(forResource: "app", ofType: "js") else {
            return nil
        }

        do {
            let app = try String(contentsOfFile: appJsPath, encoding: String.Encoding.utf8)
            print(app)
            _ = context?.evaluateScript(app)
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }
        
        return context
    }()
    
    var window: UIWindow?
//    var myModel: Int = 0
    var myLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let containerSize: CGSize = self.view.bounds.size
        
        let rect = context?.objectForKeyedSubscript("Rect")
        print(rect ?? "does not exist")
        
        let root = self.view!
        root.backgroundColor = .white
        root.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)
//        root.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.width = YGValue(containerSize.width)
//            layout.height = YGValue(containerSize.height)
//            layout.alignItems = .center
//            layout.justifyContent = .center
//        }
        
        myLabel = context?.objectForKeyedSubscript("myLabel").toObjectOf(UILabel.self) as! UILabel!
//        myLabel = UILabel()
//        myLabel.textColor = .black
        myLabel.frame = CGRect(x: 180, y: 300, width: 100, height: 20)
        myLabel.text = "hello"
//        myLabel.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.marginBottom = 25
//        }
//        updateLabel(myLabel)
//        _ = context?.objectForKeyedSubscript("updateLabel").call(withArguments: [])

        root.addSubview(myLabel)
        
//        let buttonRow: UIView = UIView()
//        buttonRow.frame = CGRect(x: 50, y: 400, width: 350, height: 30)
//        buttonRow.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.flexDirection = .row
//        }
//        root.addSubview(buttonRow)
        
        let incrementButton: UIButton = UIButton.init(type: .system)
        incrementButton.setTitle("Increment", for: .normal)
        incrementButton.setTitleColor(.green, for: .normal)
        incrementButton.addTarget(self, action: .incrementAction, for: .touchUpInside)
        incrementButton.frame = CGRect(x: 50, y: 400, width: 100, height: 20)
//        incrementButton.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.marginHorizontal = 20
//        }
//        buttonRow.addSubview(incrementButton)
        root.addSubview(incrementButton)
        
        let decrementButton: UIButton = UIButton.init(type: .system)
        decrementButton.setTitle("Decrement", for: .normal)
        decrementButton.setTitleColor(.red, for: .normal)
        decrementButton.addTarget(self, action: .decrementAction, for: .touchUpInside)
        decrementButton.frame = CGRect(x: 250, y: 400, width: 100, height: 20)
//        decrementButton.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.marginHorizontal = 20
//        }
//        buttonRow.addSubview(decrementButton)
        root.addSubview(decrementButton)
        
//        root.yoga.applyLayout(preservingOrigin: true)
    }
    
    func incrementAction() {
        _ = context?.objectForKeyedSubscript("incrementAction").call(withArguments: [])
    }
    
    func decrementAction() {
        _ = context?.objectForKeyedSubscript("decrementAction").call(withArguments: [])
    }

//    func updateLabel(_ label: UILabel) {
//        context!.objectForKeyedSubscript("updateLabel").call(withArguments: [myModel])
//        label.text = String(myModel)
//        label.yoga.markDirty()
//        self.view.yoga.applyLayout(preservingOrigin: true)
//    }
//
//    func incrementAction(_ sender: UIButton) {
//        myModel += 1
//        updateLabel(myLabel)
//    }
//    
//    func decrementAction(_ sender: UIButton) {
//        myModel -= 1
//        updateLabel(myLabel)
//    }
    
}

