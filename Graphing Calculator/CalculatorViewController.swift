//
//  ViewController.swift
//  Calculator_1
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as?UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GrapherViewController {
            if let identifier = segue.identifier {
                switch identifier {
                    case "Show Plot":
                        gvc.brain = brain
                        gvc.title = brain.description
                    default: break
                }
            }
        }
    }
    
    @IBAction func appendDIgit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit != "." || display.text!.range(of: ".") == nil) {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    var displayValue : Double? {
        get {
            if let result = NumberFormatter().number(from: display.text!) {
                return result.doubleValue
            }
            return nil
        }
        set {
            let result = newValue ?? 0.0
            display.text = "\(result)"
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter();
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    @IBAction func enterConstant(_ sender: UIButton) {
        let symbol = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = brain.performOperation(symbol)
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.pushOperand(displayValue!)
    }
    
    @IBAction func putEnter() {
        history.text = history.text! + "="
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        brain = CalculatorBrain()
        displayValue = 0
    }
    @IBAction func backspace() {
        display.text = "\(display.text!.characters.removeLast())"
        if display.text!.characters.count == 0 {
            userIsInTheMiddleOfTypingANumber = false
            display.text = "0"
        }
    }
    @IBAction func changeSign() {
        let operation = "±"
        if userIsInTheMiddleOfTypingANumber {
            if display.text?.range(of: "-") == nil {
                display.text = "-" + display.text!
            }
            else {
               display.text = "\(display.text!.characters.removeLast())"
            }
        }
        else {
            displayValue = brain.performOperation(operation)
        }
    }
    @IBAction func toMemory() {
        brain.variableValues["M"] = displayValue
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.evaluate()
    }
    
    @IBAction func enterVariable(_ sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        let variableName = sender.currentTitle!
        displayValue = brain.pushOperand(variableName)
    }
}
  
