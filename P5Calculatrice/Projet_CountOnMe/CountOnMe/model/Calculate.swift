//
//  calculate.swift
//  CountOnMe
//
//  Created by Adam Mabrouki on 10/04/2020.
//  Copyright © 2020 Vincent Saluzzo. All rights reserved.
//

import Foundation


// MARK: - Protocol

protocol DisplayDelegate: class {
    func alertMessage(text: String)
    func updateCalcul(result: String)
}

final class Calculate {
    weak var delegate: DisplayDelegate?
    
    //MARK: -Enum
    
    enum operators: String {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "*"
        case division = "÷"
    }
    
    //MARK: - Propreties
    
    /// change text when modify 
    var text = String() {
        didSet {
            delegate?.updateCalcul(result: text)
        }
    }
    
    
    ///This array contains each element of the expression
    private var elements: [String] {
        var elements =  text.split(separator: " ").map { "\($0)" }
        if elements.first == "-" {
            elements[1] = "-" + elements[1]
            elements.removeFirst()
        }
        return elements
    }
    
    ///Checks if the last element of the expression is a math operator
    private var expressionIsCorrect: Bool {
        return elements.last != "+" && elements.last != "*" && elements.last != "÷" &&  elements.last != "-"
    }
    
    private var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-" && elements.last != "*" && elements.last != "÷"
    }
    
    /// check if there is enought element to caculate
    private  var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    /// check if  there is element to calculate
    private var expressionHaveResult: Bool {
        return text.firstIndex(of: "=") != nil
    }
    
    /// check if attempt to divide by 0
    private  var divideByZero: Bool {
        return text.contains("÷ 0")
    }
    
    // MARK: - Methods
    
    /// reset text view
    func refresh ()   {
        text = ""
    }
    
    /// add number to calculation
    func addNumber(numberText: String)  {
        if expressionHaveResult {
            text = ""  }
        text.append(numberText)
    }
    
    /// append a opeator
    func addOperator(operatoree:operators)  {
        if expressionHaveResult {
            delegate?.alertMessage(text: "Vous ne pouvez pas ajouter d'operateur ")
        } // check if a operator can be added
        if (expressionIsCorrect && canAddOperator && !text.isEmpty) || (text.isEmpty && operatoree == .subtraction)  {
            text.append(" " + operatoree.rawValue + " ")
        } else {
            delegate?.alertMessage(text: "le calcul ne peut pas commencer par cet operateur ")
        }
    }
    
    /// check the order of calculation
    private func priority(expression: [String]) -> [String] {
        var priorExpression: [String] = expression //because we can't modify the constant in parameter
        while priorExpression.contains("*") || priorExpression.contains("÷") {
            if let index = priorExpression.firstIndex(where: {$0 == "*" || $0 == "÷" } ) {
                let operand = priorExpression[index]
                guard let leftSide = Double(priorExpression[index - 1]) else { return [] }
                guard let rightSide = Double(priorExpression[index + 1]) else { return [] }
                let calcul: Double
                if operand == "*" {
                    calcul = leftSide * rightSide
                } else {
                    calcul = leftSide / rightSide
                }
                priorExpression[index - 1] = String(calcul)// display the result
                priorExpression.remove(at: index + 1) // remove the others elements
                priorExpression.remove(at: index)
            }
        }
        return priorExpression
    }
    
    /// display total result of calculation
    func total()  {
        guard expressionIsCorrect else {
            delegate?.alertMessage(text: "Entrez une expréssion correcte!")
            return
        }
        guard expressionHaveEnoughElement else {
            delegate?.alertMessage(text: "Démarrez un nouveau calcul")
            return
        }
        guard !divideByZero else {
            delegate?.alertMessage(text: "La division par zéro n'existe pas")
            text = ""
            return
        }
        var operationsToReduce = priority(expression: elements)
        while operationsToReduce.count > 1 {
            print("\(elements[1])")
            guard let left = Double(operationsToReduce[0]) else {  delegate?.alertMessage(text: "Le calcul ne peut pas commencer par cet opérateur")
                return }
            let operand = operationsToReduce[1]
            guard let right = Double(operationsToReduce[2]) else { return }
            var result: Double
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            default: return
            }
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        guard let result = operationsToReduce.first else { return }
        guard let resultDoubled = Double(result) else { return }
        text.append(" = \(formatResult(result:resultDoubled))")
    }
    ////  reduce number of digit display
    private func formatResult(result: Double) -> String {
        let formatter = NumberFormatter()// reduce the number of digit display on result
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 0
        guard let resultFormated = formatter.string(from: NSNumber(value: result)) else { return String() }
        return resultFormated
    }
}

