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
  
  override func drawRect(rect: CGRect) {
    let padding = floor(0.25 * CGRectGetHeight(rect))
    let insetRect = CGRectInset(rect, padding, padding)
    
    let glassRadius = 0.4 * CGRectGetWidth(insetRect)
    let center = CGPointMake(CGRectGetMinX(insetRect) + glassRadius, CGRectGetMinY(insetRect) + glassRadius)
    
    // Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPoint(x: center.x + sin(CGFloat(M_PI_4))*glassRadius, y: center.y + cos(CGFloat(M_PI_4))*glassRadius))
    bezierPath.addArcWithCenter(center, radius: glassRadius, startAngle: CGFloat(M_PI_4), endAngle: CGFloat(M_PI_4 + 2.0*M_PI), clockwise: true)
    bezierPath.addLineToPoint(CGRectGetMax(insetRect))
    
    tintColor.setStroke()
    bezierPath.lineWidth = strokeWidth
    bezierPath.stroke()
  }
}

public func CGRectGetMax(rect: CGRect) -> CGPoint {
  return CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect))
}
