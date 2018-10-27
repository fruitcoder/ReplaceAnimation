//
//  ThreeDotButton.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 09/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

@IBDesignable class ThreeDotButton: UIButton {
    @IBInspectable var verticalInset : CGFloat = 10.0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var dotRadius : CGFloat = 2.0 {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: rect.midX - floor(dotRadius / 2.0), dy: verticalInset)
        let padding = CGFloat((insetRect.height - 6.0 * dotRadius) / 2.0)// vertical padding between dots
        let center1 = CGPoint(x: insetRect.midX,y: insetRect.origin.y + dotRadius)
        let center2 = CGPoint(x: insetRect.midX, y: insetRect.origin.y + 3.0 * dotRadius + padding)
        let center3 = CGPoint(x: insetRect.midX, y: insetRect.origin.y + 5.0 * dotRadius + 2.0 * padding)
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: center1)
        bezierPath.addArc(withCenter: center1, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*Double.pi), clockwise: true)
        bezierPath.move(to: center2)
        bezierPath.addArc(withCenter: center2, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*Double.pi), clockwise: true)
        bezierPath.move(to: center3)
        bezierPath.addArc(withCenter: center3, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*Double.pi), clockwise: true)
        
        tintColor.setFill()
        bezierPath.fill()
    }
}
