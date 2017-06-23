import UIKit
import YogaKit

fileprivate extension Selector {
    static let incrementAction =
        #selector(ViewController.incrementAction(_:))
    static let decrementAction =
        #selector(ViewController.decrementAction(_:))
}

class ViewController: UIViewController {
    
    var window: UIWindow?
    var myModel: Int = 0
    var myLabel: UILabel!

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
            layout.alignItems = .center
            layout.justifyContent = .center
        }

        myLabel = UILabel()
        myLabel.textColor = .black
        myLabel.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginBottom = 25
        }
        updateLabel(myLabel)
        root.addSubview(myLabel)

        let buttonRow: UIView = UIView()
        buttonRow.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = .row
        }
        root.addSubview(buttonRow)
        
        let incrementButton: UIButton = UIButton.init(type: .system)
        incrementButton.setTitle("Increment", for: .normal)
        incrementButton.setTitleColor(.green, for: .normal)
        incrementButton.addTarget(self, action: .incrementAction, for: .touchUpInside)
        incrementButton.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginHorizontal = 20
        }
        buttonRow.addSubview(incrementButton)
        
        let decrementButton: UIButton = UIButton.init(type: .system)
        decrementButton.setTitle("Decrement", for: .normal)
        decrementButton.setTitleColor(.red, for: .normal)
        decrementButton.addTarget(self, action: .decrementAction, for: .touchUpInside)
        decrementButton.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginHorizontal = 20
        }
        buttonRow.addSubview(decrementButton)
        
        root.yoga.applyLayout(preservingOrigin: true)
    }
    
    func updateLabel(_ label: UILabel) {
        label.text = String(myModel)
        label.yoga.markDirty()
        self.view.yoga.applyLayout(preservingOrigin: true)
    }
    
    func incrementAction(_ sender: UIButton) {
        myModel += 1
        updateLabel(myLabel)
    }
    
    func decrementAction(_ sender: UIButton) {
        myModel -= 1
        updateLabel(myLabel)
    }

}

