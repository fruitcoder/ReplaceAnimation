//
//  MailButton.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 06/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

class CloseLayer : CALayer {
  override func drawInContext(ctx: CGContext) {
    CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor);
    
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetLineJoin(ctx, .Round);
    
    CGContextMoveToPoint(ctx, bounds.size.width * 0.35, bounds.size.height * 0.35);
    CGContextAddLineToPoint(ctx, bounds.size.width * 0.65, bounds.size.height * 0.65);

    CGContextMoveToPoint(ctx, bounds.size.width * 0.35, bounds.size.height * 0.65);
    CGContextAddLineToPoint(ctx, bounds.size.width * 0.65, bounds.size.height * 0.35);
    
    CGContextStrokePath(ctx);
  }
}

class PlaneLayer : CALayer {
  override func drawInContext(ctx: CGContext) {
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(bounds.minX + 16.0/56.0 * bounds.width, bounds.minY + 14.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 46.0/56.0 * bounds.width, bounds.minY + 29.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 16.0/56.0 * bounds.width, bounds.minY + 42.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 16.0/56.0 * bounds.width, bounds.minY + 29.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 38.0/56.0 * bounds.width, bounds.minY + 29.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 16.0/56.0 * bounds.width, bounds.minY + 23.0/56.0 * bounds.height))
    bezierPath.addLineToPoint(CGPointMake(bounds.minX + 16.0/56.0 * bounds.width, bounds.minY + 14.0/56.0 * bounds.height))
    bezierPath.closePath()
    
    CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
    CGContextAddPath(ctx, bezierPath.CGPath)
    CGContextFillPath(ctx)
  }
}

enum ButtonState {
  case Default, Loading
}

class MailButton: UIButton {
  private var closeLayer : CloseLayer!
  private var planeLayer : PlaneLayer!
  private var circleLayer : CALayer!
  
  private(set) var buttonState : ButtonState = .Default
  
  var planeRotation : CGFloat = 0.0 {
    didSet {
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      planeLayer.transform = CATransform3DMakeRotation(planeRotation, 0, 0, 1)
      CATransaction.commit()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    addTargets()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
    addTargets()
  }
  
  private func setup() {
    
    circleLayer = CALayer()
    circleLayer.frame = self.bounds
    circleLayer.cornerRadius = bounds.width/2.0
    circleLayer.backgroundColor = layer.backgroundColor
    
    layer.addSublayer(circleLayer)
    layer.backgroundColor = nil // copied backgroundColor from button layer to circleLayer
    
    circleLayer.cornerRadius = bounds.width/2.0
    circleLayer.shadowPath = UIBezierPath(ovalInRect: self.bounds).CGPath
    circleLayer.shadowOpacity = 0.7
    circleLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    
    closeLayer = CloseLayer()
    closeLayer.frame = self.bounds
    closeLayer.contentsScale = UIScreen.mainScreen().scale
    
    circleLayer.addSublayer(closeLayer)
    closeLayer.setNeedsDisplay()
    showCLose(false, animated: false)
    
    planeLayer = PlaneLayer()
    planeLayer.frame = self.bounds
    planeLayer.contentsScale = UIScreen.mainScreen().scale
    
    circleLayer.addSublayer(planeLayer)
    planeLayer.setNeedsDisplay()
  }
  
  private func addTargets() {
    self.addTarget(self, action: #selector(MailButton.touchDown(_:)), forControlEvents: UIControlEvents.TouchDown)
    self.addTarget(self, action: #selector(MailButton.touchUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    self.addTarget(self, action: #selector(MailButton.touchDragExit(_:)), forControlEvents: UIControlEvents.TouchDragExit)
    self.addTarget(self, action: #selector(MailButton.touchDragEnter(_:)), forControlEvents: UIControlEvents.TouchDragEnter)
    self.addTarget(self, action: #selector(MailButton.touchCancel(_:)), forControlEvents: UIControlEvents.TouchCancel)
  }
  
  internal func touchDown(sender: MailButton) {
    animateOnTouch(true)
  }
  internal func touchUpInside(sender: MailButton) {
//    if buttonState == .Loading {
//      
//    }
    animateOnTouch(false)
  }
  internal func touchDragExit(sender: MailButton) {
    animateOnTouch(false)
  }
  internal func touchDragEnter(sender: MailButton) {
    animateOnTouch(true)
  }
  internal func touchCancel(sender: MailButton) {
    animateOnTouch(false)
  }

  // limit touch to circle path
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    return UIBezierPath(ovalInRect: self.bounds).containsPoint(point) ? self : nil
  }

  private func animateOnTouch(inside : Bool) {
    if !inside {
      // reset plane layer properties
      planeLayer.opacity = buttonState == .Default ? 1.0 : 0.0
      planeLayer.transform = CATransform3DIdentity

      // reset close layer properties
      closeLayer.opacity = buttonState == .Loading ? 1.0 : 0.0
      closeLayer.transform = CATransform3DIdentity
      
      // reset circle layer properties
      circleLayer.shadowOpacity = 0.7
      circleLayer.transform = CATransform3DIdentity
      return
    }
    
    let opacity : Float = 0.4
    let rotation : CGFloat = -0.1
    let scale : CGFloat = 0.9
    
    let rotationTransform = CATransform3DMakeRotation(rotation, 0, 0, 1)
    let scaleTransform = CATransform3DMakeScale(scale, scale, 1.0)
    
    // update main cirle, the scale will also influence the sublayers
    circleLayer.transform = scaleTransform
    circleLayer.shadowOpacity = 0.3
    
    switch buttonState {
    case .Default:
      planeLayer.opacity = opacity
      planeLayer.transform = rotationTransform
    case .Loading:
      closeLayer.transform = rotationTransform
      closeLayer.opacity = opacity
    }
  }

  private func showLayer(layer : CALayer, show : Bool, animated : Bool) {
    CATransaction.begin()
    CATransaction.setDisableActions(!animated)
    
    layer.opacity = show ? 1.0 : 0.0
    
    CATransaction.commit()
  }
  
  func showPlane(show : Bool, animated : Bool) {
    showLayer(planeLayer, show : show, animated: animated)
  }
  
  func showCLose(show : Bool, animated : Bool) {
    showLayer(closeLayer, show : show, animated: animated)
  }
  
  
  // MARK: - Public interface
  func setButtonState(state : ButtonState, animated : Bool) {
    buttonState = state
    showPlane(state == .Default, animated: animated)
    showCLose(state == .Loading, animated: animated)
  }
  
  func switchButtonState(animated animated : Bool) {
    setButtonState(buttonState == .Default ? .Loading : .Default, animated: animated)
  }
}
