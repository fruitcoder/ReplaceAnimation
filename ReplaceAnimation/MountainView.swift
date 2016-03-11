//
//  MountainView.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 07/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

class MountainLayer: CALayer {
  var peakXToWidthRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if peakXToWidthRatio <= 1.0 && peakXToWidthRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }
  
  var leftYToHeightRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if leftYToHeightRatio <= 1.0 && leftYToHeightRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }
  
  var rightYToHeightRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if rightYToHeightRatio <= 1.0 && rightYToHeightRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }

  override func drawInContext(ctx: CGContext) {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(frame.origin.x, frame.origin.y + frame.size.height))
    bezierPath.addLineToPoint(CGPointMake(frame.origin.x, frame.origin.y + leftYToHeightRatio * frame.size.height))
    bezierPath.addLineToPoint(CGPointMake(frame.origin.x + peakXToWidthRatio * frame.size.width, frame.origin.y))
    bezierPath.addLineToPoint(CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + rightYToHeightRatio * frame.size.height))
    bezierPath.addLineToPoint(CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height))
    bezierPath.closePath()
    
    CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
    CGContextAddPath(ctx, bezierPath.CGPath)
    CGContextFillPath(ctx)
  }
}

@IBDesignable
class MountainView: UIView {
  @IBInspectable var peakXToWidthRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if peakXToWidthRatio <= 1.0 && peakXToWidthRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }
  
  @IBInspectable var leftYToHeightRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if leftYToHeightRatio <= 1.0 && leftYToHeightRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }

  @IBInspectable var rightYToHeightRatio: CGFloat = 0.5 {
    // Update your UI when value changes
    didSet {
      if rightYToHeightRatio <= 1.0 && rightYToHeightRatio >= 0.0 {
        self.setNeedsDisplay()
      }
    }
  }
  
  override func didMoveToSuperview() {
    setNeedsDisplay()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    setNeedsDisplay()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func drawRect(rect: CGRect) {
    // Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(rect.origin.x, rect.origin.y + rect.size.height))
    bezierPath.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y + leftYToHeightRatio * rect.size.height))
    bezierPath.addLineToPoint(CGPointMake(rect.origin.x + peakXToWidthRatio * rect.size.width, rect.origin.y))
    bezierPath.addLineToPoint(CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rightYToHeightRatio * rect.size.height))
    bezierPath.addLineToPoint(CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height))
    bezierPath.closePath()
    
    tintColor.setFill()
    bezierPath.fill()
  }
}
