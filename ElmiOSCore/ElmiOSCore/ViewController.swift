import UIKit
import YogaKit
import JavaScriptCore

class ViewController: UIViewController {

    static var timerId = 0

    lazy var jsContext: JSContext? = {
        let context: JSContext = JSContext()

        // patch context

        let initialRender: @convention(block) ([String : Any]) -> Void = { (view) in
            VirtualUIKit.initialRender(view: view)
        }
        context.setObject(initialRender, forKeyedSubscript: "initialRender" as (NSCopying & NSObjectProtocol)!)
        
        let applyPatches: @convention(block) ([String : Any]) -> Void = { (patches) in
            var patches = patches
            VirtualUIKit.applyPatches(&patches)
        }
        context.setObject(applyPatches, forKeyedSubscript: "applyPatches" as (NSCopying & NSObjectProtocol)!)

        // add missing BOM stuff

        let setTimeout: @convention(block) (JSValue, Double) -> Void = { (function, timeout) in
            print("setTimeout")
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: { () -> Void in
                function.call(withArguments: [])
            })
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as (NSCopying & NSObjectProtocol)!)

//        let setInterval: @convention(block) (JSValue, Double) -> Void = { (function, interval) in
//            Timer.scheduledTimer(timeInterval: interval / 1000.0, repeats: true, block: { (timer) in
//                function.call(withArguments: [])
//            })
//            return
//        }

//        func setIntervalHelp(function: JSValue, interval: Double) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: { () -> Void in
//                function.call(withArguments: [])
//                setIntervalHelp(function: function, interval: interval)
//            })
//        }
        let setInterval: @convention(block) (JSValue, Double) -> Int = { (function, interval) in
            print("setInterval")
            Timer.scheduledTimer(withTimeInterval: interval / 1000.0, repeats: true, block: { (timer) in function.call(withArguments: []) })
            timerId += 1
            return timerId
        }
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as (NSCopying & NSObjectProtocol)!)

        let clearInterval: @convention(block) (Int) -> Void = { id in
            print(id)
        }
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as (NSCopying & NSObjectProtocol)!)

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
        
        let containerSize: CGSize = self.view.bounds.size
        
        let root = self.view!
        root.backgroundColor = .white
        root.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(containerSize.width)
            layout.height = YGValue(containerSize.height)
        }
        
        _ = jsContext?.objectForKeyedSubscript("ready").call(withArguments: [])
    }
    
    func addToRootView(subview: UIView) {
        self.view.addSubview(subview)
        self.view.yoga.applyLayout(preservingOrigin: true)
    }

}

