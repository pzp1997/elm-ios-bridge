import UIKit
import YogaKit
import JavaScriptCore

class ViewController: UIViewController {
    
    lazy var jsContext: JSContext? = {
        let context: JSContext = JSContext()

        // patch context

        let initialRender: @convention(block) ([String : Any]) -> Void = { (view) in
            if let renderedView = VirtualUIKit.render(virtualView: view) {
                let containerSize: CGSize = self.view.bounds.size
                
                let root = self.view!
                root.backgroundColor = .white
                root.configureLayout { (layout) in
                    layout.isEnabled = true
                    layout.width = YGValue(containerSize.width)
                    layout.height = YGValue(containerSize.height)
                }
                
                root.addSubview(renderedView)
                root.yoga.applyLayout(preservingOrigin: true)
                
                // DEBUG
                print(renderedView)
            }
        }
        context.setObject(initialRender, forKeyedSubscript: "initialRender" as (NSCopying & NSObjectProtocol)!)
        
        // console
        
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("JS Console: " + message)
        }
        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as (NSCopying & NSObjectProtocol)!)
        
        // exception handler
        
        context.exceptionHandler = { context, exception in
            print("JS Error: \(exception?.description ?? "unknown error")")
        }
        
        // load app.js

        guard let appJsPath = Bundle.main.path(forResource: "app", ofType: "js") else {
            return nil
        }
        
        do {
            let app = try String(contentsOfFile: appJsPath, encoding: String.Encoding.utf8)
            _ = context.evaluateScript(app)
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }
        
        return context
    }()
    
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
//        let containerSize: CGSize = self.view.bounds.size
//        
//        let root = self.view!
//        root.backgroundColor = .white
//        root.configureLayout { (layout) in
//            layout.isEnabled = true
//            layout.width = YGValue(containerSize.width)
//            layout.height = YGValue(containerSize.height)
//            layout.alignItems = .center
//            layout.justifyContent = .center
//        }
        
        _ = jsContext?.objectForKeyedSubscript("ready").call(withArguments: [])
    }
    

}

