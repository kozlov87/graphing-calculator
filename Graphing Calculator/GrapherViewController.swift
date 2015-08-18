//
//  GrapherViewController.swift
//  Graphing Calculator
//
//  Created by Иван Павлов on 27.07.15.
//  Copyright (c) 2015 Иван Павлов. All rights reserved.
//

import UIKit

class GrapherViewController: UIViewController, GrapherViewDataSource {
    
    @IBOutlet var grapherView: GrapherView! {
        didSet {
            grapherView.dataSource = self
        }
    }
    
    var brain : CalculatorBrain?
    func evaluationForVariable(x: Double) -> Double? {
        brain?.variableValues["M"] = x
        return brain?.evaluate()
    }
    
    @IBAction func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            grapherView.pointsPerUnit *= gesture.scale
            gesture.scale = 1
        }
    }
    
    @IBAction func movePlot(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed {
            let translation = gesture.translationInView(grapherView)
            let yChange = translation.y, xChange = translation.x
            if yChange != 0 ||  xChange != 0{
                let newOffset = (x: grapherView.originOffset.x + xChange, y : grapherView.originOffset.y + yChange)
                grapherView.originOffset = newOffset
                gesture.setTranslation(CGPointZero, inView: grapherView)
            }
        }
    }
    @IBAction func moveOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let position = gesture.locationInView(grapherView)
            let offset = (x: position.x - grapherView.center.x, y: position.y - grapherView.center.y)
            let newOffset = (x: grapherView.originOffset.x - offset.x, y : grapherView.originOffset.y -
                offset.y)
            grapherView.originOffset = newOffset
        }
    }
}
