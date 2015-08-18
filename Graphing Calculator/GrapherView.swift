//
//  GrapherView.swift
//  Graphing Calculator
//
//  Created by Иван Павлов on 28.07.15.
//  Copyright (c) 2015 Иван Павлов. All rights reserved.
//

import UIKit

protocol GrapherViewDataSource: class {
    func evaluationForVariable(x : Double) -> Double?
}

@IBDesignable
class GrapherView: UIView {
    weak var dataSource : GrapherViewDataSource?
    
    let drawer = AxesDrawer()
    
    @IBInspectable
    var pointsPerUnit = CGFloat(50) { didSet{setNeedsDisplay() } }
    
    @IBInspectable
    var originOffset = (x: CGFloat(0), y: CGFloat(0)){ didSet{setNeedsDisplay() } }
    
    var originCenter: CGPoint {
        get{
            let result = CGPoint(x: center.x + originOffset.x, y: center.y + originOffset.y)
            return result
        }
    }
    
    @IBInspectable
    var pointsOnView = 100 { didSet{setNeedsDisplay() } }
    
    private func bezierPathForFunction() -> UIBezierPath {
        var path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let distancePerPoint: CGFloat = width / CGFloat(pointsOnView)
        
        var points = [CGPoint]()
        
        
        var currentPoint = CGFloat(0) {
            didSet {
                currentPoint = max(CGFloat(0), min(width, currentPoint))
            }
        }
        
        for pointNum in 0...pointsOnView {
            let pointValue = (currentPoint - width / 2 - originOffset.x) / pointsPerUnit
            if let evaluation = dataSource?.evaluationForVariable(Double(pointValue)) {
                let y = -CGFloat(evaluation) * pointsPerUnit + height / 2 + originOffset.y
                points.append(CGPoint(x: currentPoint, y: y))
            }
            currentPoint += distancePerPoint
        }
        if points.count > 0 {
            path.moveToPoint(points[0])
            for point in points {
                path.addLineToPoint(point)
            }
        }
        return path
    }
    
    override func drawRect(rect: CGRect) {
        drawer.drawAxesInRect(bounds, origin: originCenter, pointsPerUnit: pointsPerUnit)
        bezierPathForFunction().stroke()
    }
    
}
