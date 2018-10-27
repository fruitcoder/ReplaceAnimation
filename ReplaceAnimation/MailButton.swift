//
//  MailButton.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 06/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

class CloseLayer : CALayer {
    override func draw(in ctx: CGContext) {
        ctx.setStrokeColor(UIColor.white.cgColor);
        
        ctx.setLineWidth(2.0);
        ctx.setLineJoin(.round);
        
        
        ctx.move(to: CGPoint(x: bounds.size.width * 0.35, y: bounds.size.height * 0.35))
        ctx.addLine(to: CGPoint(x: bounds.size.width * 0.65, y: bounds.size.height * 0.65))
        
        ctx.move(to: CGPoint(x: bounds.size.width * 0.35, y: bounds.size.height * 0.65))
        ctx.addLine(to: CGPoint(x: bounds.size.width * 0.65, y: bounds.size.height * 0.35))
        
        ctx.strokePath()
    }
}

class PlaneLayer : CALayer {
    override func draw(in ctx: CGContext) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: bounds.minX + 16.0/56.0 * bounds.width, y: bounds.minY + 14.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 46.0/56.0 * bounds.width, y: bounds.minY + 29.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 16.0/56.0 * bounds.width, y: bounds.minY + 42.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 16.0/56.0 * bounds.width, y: bounds.minY + 29.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 38.0/56.0 * bounds.width, y: bounds.minY + 29.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 16.0/56.0 * bounds.width, y: bounds.minY + 23.0/56.0 * bounds.height))
        bezierPath.addLine(to: CGPoint(x: bounds.minX + 16.0/56.0 * bounds.width, y: bounds.minY + 14.0/56.0 * bounds.height))
        bezierPath.close()
        
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addPath(bezierPath.cgPath)
        ctx.fillPath()
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
        circleLayer.shadowPath = UIBezierPath(ovalIn: self.bounds).cgPath
        circleLayer.shadowOpacity = 0.7
        circleLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
        closeLayer = CloseLayer()
        closeLayer.frame = self.bounds
        closeLayer.contentsScale = UIScreen.main.scale
        
        circleLayer.addSublayer(closeLayer)
        closeLayer.setNeedsDisplay()
        showCLose(show: false, animated: false)
        
        planeLayer = PlaneLayer()
        planeLayer.frame = self.bounds
        planeLayer.contentsScale = UIScreen.main.scale
        
        circleLayer.addSublayer(planeLayer)
        planeLayer.setNeedsDisplay()
    }
    
    private func addTargets() {
        self.addTarget(self, action: #selector(MailButton.touchDown(_:)), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(MailButton.touchUpInside(_:)), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(MailButton.touchDragExit(_:)), for: UIControl.Event.touchDragExit)
        self.addTarget(self, action: #selector(MailButton.touchDragEnter(_:)), for: UIControl.Event.touchDragEnter)
        self.addTarget(self, action: #selector(MailButton.touchCancel(_:)), for: UIControl.Event.touchCancel)
    }
    
    @objc internal func touchDown(_ sender: MailButton) {
        animateOnTouch(inside: true)
    }
    @objc internal func touchUpInside(_ sender: MailButton) {
        //    if buttonState == .Loading {
        //      
        //    }
        animateOnTouch(inside: false)
    }
    @objc internal func touchDragExit(_ sender: MailButton) {
        animateOnTouch(inside: false)
    }
    @objc internal func touchDragEnter(_ sender: MailButton) {
        animateOnTouch(inside: true)
    }
    @objc internal func touchCancel(_ sender: MailButton) {
        animateOnTouch(inside: false)
    }
    
    // limit touch to circle path
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return UIBezierPath(ovalIn: self.bounds).contains(point) ? self : nil
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
        showLayer(layer: planeLayer, show : show, animated: animated)
    }
    
    func showCLose(show : Bool, animated : Bool) {
        showLayer(layer: closeLayer, show : show, animated: animated)
    }
    
    
    // MARK: - Public interface
    func setButtonState(state : ButtonState, animated : Bool) {
        buttonState = state
        showPlane(show: state == .Default, animated: animated)
        showCLose(show: state == .Loading, animated: animated)
    }
    
    func switchButtonState(animated : Bool) {
        setButtonState(state: buttonState == .Default ? .Loading : .Default, animated: animated)
    }
}
