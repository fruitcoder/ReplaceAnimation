//
//  SearchButton.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 10/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

@IBDesignable class SearchButton: UIButton {
    @IBInspectable var strokeWidth : CGFloat = 2.0 {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        let padding = floor(0.25 * rect.height)
        let insetRect = rect.insetBy(dx: padding, dy: padding)
        
        let glassRadius = 0.4 * insetRect.width
        let center = CGPoint(x: insetRect.minX + glassRadius, y: insetRect.minY + glassRadius)
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: center.x + sin(CGFloat(Double.pi/4))*glassRadius, y: center.y + cos(CGFloat(Double.pi/4))*glassRadius))
        bezierPath.addArc(withCenter: center, radius: glassRadius, startAngle: CGFloat(Double.pi/4), endAngle: CGFloat(Double.pi/4 + 2.0*Double.pi), clockwise: true)
        bezierPath.addLine(to: CGRectGetMax(rect: insetRect))
        
        tintColor.setStroke()
        bezierPath.lineWidth = strokeWidth
        bezierPath.stroke()
    }
}

public func CGRectGetMax(rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.maxX, y: rect.maxY)
}
