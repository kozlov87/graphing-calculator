//
//  ViewController.swift
//  Calculator_1
//
//  Created by Иван Павлов on 06.07.15.
//  Copyright (c) 2015 Иван Павлов. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as?UIViewController
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
    
    @IBAction func appendDIgit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit != "." || display.text!.rangeOfString(".") == nil) {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    var displayValue : Double? {
        get {
            if let result = NSNumberFormatter().numberFromString(display.text!) {
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
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter();
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    @IBAction func enterConstant(sender: UIButton) {
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
        display.text = dropLast(display.text!)
        if count(display.text!) == 0 {
            userIsInTheMiddleOfTypingANumber = false
            display.text = "0"
        }
    }
    @IBAction func changeSign() {
        let operation = "±"
        if userIsInTheMiddleOfTypingANumber {
            if display.text?.rangeOfString("-") == nil {
                display.text = "-" + display.text!
            }
            else {
               display.text = dropFirst(display.text!)
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
    
    @IBAction func enterVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        let variableName = sender.currentTitle!
        displayValue = brain.pushOperand(variableName)
    }
}
  