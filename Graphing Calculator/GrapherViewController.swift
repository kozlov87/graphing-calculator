//
//  GrapherViewController.swift
//  Graphing Calculator
//

import UIKit

class GrapherViewController: UIViewController, GrapherViewDataSource {
    
    @IBOutlet var grapherView: GrapherView! {
        didSet {
            grapherView.dataSource = self
        }
    }
    
    var brain : CalculatorBrain?
    func evaluationForVariable(_ x: Double) -> Double? {
        brain?.variableValues["M"] = x
        return brain?.evaluate()
    }
    
    @IBAction func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            grapherView.pointsPerUnit *= gesture.scale
            gesture.scale = 1
        }
    }
    
    @IBAction func movePlot(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: grapherView)
            let yChange = translation.y, xChange = translation.x
            if yChange != 0 ||  xChange != 0{
                let newOffset = (x: grapherView.originOffset.x + xChange, y : grapherView.originOffset.y + yChange)
                grapherView.originOffset = newOffset
                gesture.setTranslation(CGPoint.zero, in: grapherView)
            }
        }
    }
    @IBAction func moveOrigin(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let position = gesture.location(in: grapherView)
            let offset = (x: position.x - grapherView.center.x, y: position.y - grapherView.center.y)
            let newOffset = (x: grapherView.originOffset.x - offset.x, y : grapherView.originOffset.y -
                offset.y)
            grapherView.originOffset = newOffset
        }
    }
}
