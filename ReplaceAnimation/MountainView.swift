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
    
    override func draw(in ctx: CGContext) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        bezierPath.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + leftYToHeightRatio * frame.size.height))
        bezierPath.addLine(to: CGPoint(x: frame.origin.x + peakXToWidthRatio * frame.size.width, y: frame.origin.y))
        bezierPath.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + rightYToHeightRatio * frame.size.height))
        bezierPath.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height))
        bezierPath.close()
        
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addPath(bezierPath.cgPath)
        ctx.fillPath()
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
    
    override func draw(_ rect: CGRect) {
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        bezierPath.addLine(to: CGPoint(x: rect.origin.x,y: rect.origin.y + leftYToHeightRatio * rect.size.height))
        bezierPath.addLine(to: CGPoint(x: rect.origin.x + peakXToWidthRatio * rect.size.width, y: rect.origin.y))
        bezierPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width,y: rect.origin.y + rightYToHeightRatio * rect.size.height))
        bezierPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width,y: rect.origin.y + rect.size.height))
        bezierPath.close()
        
        tintColor.setFill()
        bezierPath.fill()
    }
}
