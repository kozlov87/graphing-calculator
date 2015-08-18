//
//  CalculatorBrain.swift
//  Calculator_1
//
//  Created by Иван Павлов on 13.07.15.
//  Copyright (c) 2015 Иван Павлов. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op : Printable{
        case Operand(Double);
        case Variable(String);
        case Constant(String, Double);
        case UnaryOperation(String, Double -> Double);
        case BinaryOperation(String, (Double, Double) -> Double);
        
        var description : String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let name):
                    return "\(name)"
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    private var opStack = [Op]();
    
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    typealias PropertyList = AnyObject
    
    var program : PropertyList  {
        get {
            return opStack.map({$0.description})
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                         newOpStack.append(op)
                    } else {
                        if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                             newOpStack.append(.Operand(operand))
                        }
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        get {
            var ans = ""
            var currentStack = opStack
            while !currentStack.isEmpty {
                let result = getDescription(currentStack)
                currentStack = result.remainingOps
                ans = ans + (result.result ?? " !!! ") + ","
            }
            return (ans != "") ? dropLast(ans) : ""
        }
    }
    
    init () {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.Constant("π", M_PI))
        learnOp(Op.UnaryOperation("±", -))
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    
    
    private func getDescription(ops : [Op]) -> (result: String?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let name):
                return (name, remainingOps)
            case .Constant(let name, _):
                return (name, remainingOps)
            case .UnaryOperation(let operation, _):
                let result = getDescription(remainingOps)
                var argument = result.result ?? "?"
                return ("\(operation) \(argument)", result.remainingOps)
            case .BinaryOperation(let operation, _):
                var argument1 = "?", argument2 = "?"
                let argument1Description = getDescription(remainingOps)
                var remainder = remainingOps
                if let argument1Value = argument1Description.result {
                    argument1 = argument1Value
                    remainder = argument1Description.remainingOps
                    let argument2Description = getDescription(argument1Description.remainingOps)
                    if let argument2Value = argument2Description.result {
                        remainder = argument2Description.remainingOps
                        argument2 = argument2Value
                    }
                }
                return ("(\(argument2)\(operation)\(argument1))", remainder)
            }
        }
        return (nil, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let name):
                return (variableValues[name], remainingOps)
            case .Constant(_, let value):
                return (value, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        println("description = \(description)")
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    func performOperation(symbol : String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}