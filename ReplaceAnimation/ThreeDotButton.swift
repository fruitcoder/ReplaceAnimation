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
  
  override func drawRect(rect: CGRect) {
    let insetRect = CGRectInset(rect, CGRectGetMidX(rect) - floor(dotRadius / 2.0), verticalInset)
    let padding = CGFloat((CGRectGetHeight(insetRect) - 6.0 * dotRadius) / 2.0)// vertical padding between dots
    let center1 = CGPointMake(CGRectGetMidX(insetRect), insetRect.origin.y + dotRadius)
    let center2 = CGPointMake(CGRectGetMidX(insetRect), insetRect.origin.y + 3.0 * dotRadius + padding)
    let center3 = CGPointMake(CGRectGetMidX(insetRect), insetRect.origin.y + 5.0 * dotRadius + 2.0 * padding)
    
    // Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(center1)
    bezierPath.addArcWithCenter(center1, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*M_PI), clockwise: true)
    bezierPath.moveToPoint(center2)
    bezierPath.addArcWithCenter(center2, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*M_PI), clockwise: true)
    bezierPath.moveToPoint(center3)
    bezierPath.addArcWithCenter(center3, radius: dotRadius, startAngle: 0, endAngle: CGFloat(2.0*M_PI), clockwise: true)
    
    tintColor.setFill()
    bezierPath.fill()
  }
}
