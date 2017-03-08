//
//  CalculatorBrain.swift
//  Calculator_1
//

import Foundation

class CalculatorBrain
{
    fileprivate enum Op : CustomStringConvertible{
        case operand(Double);
        case variable(String);
        case constant(String, Double);
        case unaryOperation(String, (Double) -> Double);
        case binaryOperation(String, (Double, Double) -> Double);
        
        var description : String {
            get {
                switch self {
                case .operand(let operand):
                    return "\(operand)"
                case .variable(let name):
                    return "\(name)"
                case .constant(let symbol, _):
                    return symbol
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    fileprivate var opStack = [Op]();
    
    fileprivate var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    typealias PropertyList = Any
    
    var program : PropertyList  {
        get {
            return opStack.map {$0.description}
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                         newOpStack.append(op)
                    } else {
                        if let operand = NumberFormatter().number(from: opSymbol)?.doubleValue {
                             newOpStack.append(.operand(operand))
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
            return (ans != "") ? "\(ans.characters.removeLast())" : ""
        }
    }
    
    init () {
        func learnOp(_ op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.constant("π", M_PI))
        learnOp(Op.unaryOperation("±", -))
        learnOp(Op.binaryOperation("×", *))
        learnOp(Op.binaryOperation("+", +))
        learnOp(Op.binaryOperation("÷") { $1 / $0 })
        learnOp(Op.binaryOperation("−") { $1 - $0 })
        learnOp(Op.unaryOperation("√", sqrt))
        learnOp(Op.unaryOperation("sin", sin))
        learnOp(Op.unaryOperation("cos", cos))
    }
    
    
    
    fileprivate func getDescription(_ ops : [Op]) -> (result: String?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .operand(let operand):
                return ("\(operand)", remainingOps)
            case .variable(let name):
                return (name, remainingOps)
            case .constant(let name, _):
                return (name, remainingOps)
            case .unaryOperation(let operation, _):
                let result = getDescription(remainingOps)
                var argument = result.result ?? "?"
                return ("\(operation) \(argument)", result.remainingOps)
            case .binaryOperation(let operation, _):
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
    
    fileprivate func evaluate(_ ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, remainingOps)
            case .variable(let name):
                return (variableValues[name], remainingOps)
            case .constant(_, let value):
                return (value, remainingOps)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
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
        print("\(opStack) = \(result) with \(remainder) left over")
        print("description = \(description)")
        return result
    }
    
    func pushOperand(_ operand: Double) -> Double?{
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
    func pushOperand(_ operand: String) -> Double? {
        opStack.append(Op.variable(operand))
        return evaluate()
    }
    
    func performOperation(_ symbol : String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}
