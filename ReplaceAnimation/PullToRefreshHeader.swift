//
//  PullToRefreshHeader.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 05/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

struct Boundary {
  let from : CGFloat
  let to : CGFloat
}

class PullToRefreshHeader: UICollectionReusableView {
  // MARK: Private properties
  private struct AnimationKey {
    static let FlyOutAnimation = "FlyOutAnimation"
    static let FlyInAnimation1 = "FlyInAnimation1"
    static let FlyInAnimation2 = "FlyInAnimation2"
  }
  private let maxPaperplaneRotation = -CGFloat(M_PI_4)
  private var planeLayerCopy : PlaneLayer?
  private var skipSecondAnimation = false
  private var wiggling = false // do you call that wiggling?
  private var finishedFirstAnimation = false
  // since the network request can be too fast, we need to store the completion block passed into finishRefreshAnimation and call it
  // in the CATransaction completion handler of the startRefreshAnimation, to avoid interrupting the first animation
  private var secondAnimationCompletion : (()->Void)? = nil
  
  // constraints
  private var mailButtonBottomConstraintRange = Boundary(from: CGFloat(5), to : -CGFloat(28))
  private var mountainsBottomConstraintRange = Boundary(from: CGFloat(-25), to: CGFloat(0))
  
  // MARK: IBOutlets
  @IBOutlet weak var fgRightTreeView: TreeView!
  @IBOutlet weak var fgMiddleTreeView: TreeView!
  @IBOutlet weak var fgLeftTreeView: TreeView!
  @IBOutlet weak var bgLeftTreeView: TreeView!
  @IBOutlet weak var bgRightTreeView: TreeView!
  
  @IBOutlet weak var mailButton: MailButton!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var fgMountainView: MountainView!
  @IBOutlet weak var mgMountainView: MountainView! // left

  // Constraints
  @IBOutlet weak var frontMountainViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var middleMountainView1BottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var middleMountainView2BottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var backMountainView1BottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var backMountainView2BottomConstraint: NSLayoutConstraint!
  
  // tree constraints foreground
  @IBOutlet weak var fgRightTreeBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgRightTreeTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgRightTreePropWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgMiddleTreePropWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgMiddleTreeBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgMiddleTreeTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgLeftTreeBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgLeftTreePropWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var fgLeftTreeTrailingConstraint: NSLayoutConstraint!
  
  // tree constraints foreground
  @IBOutlet weak var bgRightTreeBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var bgLeftTreeBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var bgLeftTreeLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var bgRightTreeLeadingConstraint: NSLayoutConstraint!
  
  // mail button costraints
  @IBOutlet weak var mailButtonBottomConstraint: NSLayoutConstraint!

  @IBAction func mailButtonPressed(sender: MailButton) {
    switch sender.buttonState {
    case .Default:
      onMailButtonPress?()
    case .Loading:
      // stop network request
      cancelRefreshAnimation()
    }
  }
  
  // MARK: Public properties
  static let Kind = "StickyHeaderLayoutAttributesKind"

  var onRefresh : (() -> Void)?
  var onMailButtonPress : (() -> Void)?
  var onCancel : (() -> Void)?
  private (set) var isLoading : Bool {
    get {
      return mailButton.buttonState == .Loading
    }
    set {
      mailButton.switchButtonState(animated : true)
    }
  }
  
  // MARK: - Functions  
  // MARK: Superclass overrides
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    guard let layoutAttributes:StickyHeaderLayoutAttributes = layoutAttributes as? StickyHeaderLayoutAttributes else { return }
    
    // when start wiggling = true, we add a wiggle animation to the trees and animate the mountains to their silent position
    if wiggling {
      fgRightTreeView.startWiggle() {
        self.wiggling = false
      }
      fgMiddleTreeView.startWiggle()
      fgLeftTreeView.startWiggle()
      bgLeftTreeView.startWiggle()
      bgRightTreeView.startWiggle()
    }
    
    // only synch tree bending with layout attributes if not currently wiggling
    if !wiggling {
      let bendingRight = (layoutAttributes.progress - 1.0)
      fgRightTreeView.currentBending = bendingRight
      fgMiddleTreeView.currentBending = bendingRight
      fgLeftTreeView.currentBending = bendingRight
      
      let bendingLeft = -(layoutAttributes.progress - 1.0)
      bgLeftTreeView.currentBending = bendingLeft
      bgRightTreeView.currentBending = bendingLeft
    }
    
    mailButton.planeRotation = max(0.0, (layoutAttributes.progress - 1.0)) * (-CGFloat(M_PI_4))
    
    // PARALLAX: first step
    if layoutAttributes.progress >= 1.0 && layoutAttributes.progress < 1.1 {
      let progress = (1.1 - layoutAttributes.progress) / 0.1 * mountainsBottomConstraintRange.from
      frontMountainViewBottomConstraint.constant = progress
      middleMountainView1BottomConstraint.constant = progress
      middleMountainView2BottomConstraint.constant = progress
      backMountainView1BottomConstraint.constant = progress
      backMountainView2BottomConstraint.constant = progress
      
      // force auto layout to calculate the correct frame for front mountain, this is necessary after view is loaded from xib since the frame is not yet calculated
      if fgMountainView.frame.width != UIScreen.mainScreen().bounds.width {
        layoutIfNeeded()
      }
      
      // Update trees
      updateTrees()
    }
    
    // second step 
    if layoutAttributes.progress >= 1.1 && layoutAttributes.progress < 1.2 {
      let progress = abs(mountainsBottomConstraintRange.from) + (1.2 - layoutAttributes.progress) / 0.1 * (mountainsBottomConstraintRange.from)
      middleMountainView1BottomConstraint.constant = progress
      middleMountainView2BottomConstraint.constant = progress
      backMountainView1BottomConstraint.constant = progress
      backMountainView2BottomConstraint.constant = progress
      
      // Update trees
      updateTrees()
    }

    // third step
    if layoutAttributes.progress >= 1.2 && layoutAttributes.progress < 1.3 {
      let progress = 2.0 * abs(mountainsBottomConstraintRange.from) + (1.3 - layoutAttributes.progress) / 0.1 * (mountainsBottomConstraintRange.from)
      backMountainView1BottomConstraint.constant = progress
      backMountainView2BottomConstraint.constant = progress
    }
    
    // fourth step : progressively set the alpha of the bottom view
    if layoutAttributes.progress < 0.25 && layoutAttributes.progress > 0.03 {
      bottomView.alpha = (0.25 - layoutAttributes.progress) / 0.22
    }
    
    // fifth step : animate the button up or down
    if layoutAttributes.progress < 0.03 && mailButtonBottomConstraint.constant != mailButtonBottomConstraintRange.to {
      mailButtonBottomConstraint.constant = mailButtonBottomConstraintRange.to
      UIView.animateWithDuration(0.2, delay: 0.0, options: [.BeginFromCurrentState], animations: { () -> Void in
        self.layoutIfNeeded()
        }, completion: nil)
    }
    
    if layoutAttributes.progress >= 0.03 && mailButtonBottomConstraint.constant != mailButtonBottomConstraintRange.from {
      mailButtonBottomConstraint.constant = mailButtonBottomConstraintRange.from
      UIView.animateWithDuration(0.2, delay: 0.0, options: [.BeginFromCurrentState], animations: { () -> Void in
        self.layoutIfNeeded()
        }, completion: nil)
    }
    
    // for fast scrolling assure values are at their boundaries
    if layoutAttributes.progress >= 0.25 { bottomView.alpha = 0.0 }
    if layoutAttributes.progress <= 0.03 { bottomView.alpha = 1.0 }
    
    if layoutAttributes.progress < 1.0 {
      frontMountainViewBottomConstraint.constant = mountainsBottomConstraintRange.from
      middleMountainView1BottomConstraint.constant = mountainsBottomConstraintRange.from
      middleMountainView2BottomConstraint.constant = mountainsBottomConstraintRange.from
      backMountainView1BottomConstraint.constant = mountainsBottomConstraintRange.from
      backMountainView2BottomConstraint.constant = mountainsBottomConstraintRange.from
      updateTrees()
    }
    
    if layoutAttributes.progress >= 1.3 {
      frontMountainViewBottomConstraint.constant = 0.0
      middleMountainView1BottomConstraint.constant = abs(mountainsBottomConstraintRange.from)
      middleMountainView2BottomConstraint.constant = abs(mountainsBottomConstraintRange.from)
      backMountainView1BottomConstraint.constant = 2.0 * abs(mountainsBottomConstraintRange.from)
      backMountainView2BottomConstraint.constant = 2.0 * abs(mountainsBottomConstraintRange.from)
      updateTrees()
    }
  }
  
  override func prepareForReuse() {
    onRefresh = nil
    onMailButtonPress = nil
    onCancel = nil
    
    planeLayerCopy?.removeAllAnimations()
    planeLayerCopy?.removeFromSuperlayer()
    planeLayerCopy = nil
  }
  
  override func awakeFromNib() {
    let screenWidth = UIScreen.mainScreen().bounds.width
    mountainsBottomConstraintRange = Boundary(from: floor(-0.07 * screenWidth), to: 0)
    mailButtonBottomConstraintRange = Boundary(from: floor(0.014 * screenWidth), to : -floor(0.078 * screenWidth))
    fgRightTreeTrailingConstraint.constant = 0.16*screenWidth
    fgMiddleTreeTrailingConstraint.constant = 0.0625*screenWidth
    fgLeftTreeTrailingConstraint.constant = 0.025*screenWidth
    bgLeftTreeLeadingConstraint.constant = 0.17*screenWidth
    bgRightTreeLeadingConstraint.constant = 0.016*screenWidth
  }
  
  // MARK: Private functions
  private func updateTrees() {
    let fgTreeBottomConstraint = fgMountainView.frame.height + frontMountainViewBottomConstraint.constant - floor(0.15 * fgMountainView.frame.height)
    
    fgRightTreeBottomConstraint.constant = fgTreeBottomConstraint
    fgMiddleTreeBottomConstraint.constant = fgTreeBottomConstraint
    fgLeftTreeBottomConstraint.constant = fgTreeBottomConstraint
    
    let bgTreeBottomConstraint = mgMountainView.frame.height + middleMountainView1BottomConstraint.constant - floor(0.1 * mgMountainView.frame.height)
    
    bgLeftTreeBottomConstraint.constant = bgTreeBottomConstraint
    bgRightTreeBottomConstraint.constant = bgTreeBottomConstraint
  }
  
  // MARK: Public interface
  func startRefreshAnimation() {
    if isLoading { return }
    else {
      mailButton.switchButtonState(animated: true) // hide original button layers
    }
    
    finishedFirstAnimation = false
    
    // set flag to react different in apply layout attributes
    wiggling = true
    
    // create copy of plane layer (might change to initWithLayer)
    planeLayerCopy = PlaneLayer()
    planeLayerCopy!.contentsScale = UIScreen.mainScreen().scale
    planeLayerCopy!.frame = mailButton.bounds
    planeLayerCopy!.transform = CATransform3DMakeRotation(maxPaperplaneRotation, 0.0, 0.0, 1.0)
    planeLayerCopy!.setNeedsDisplay()
    planeLayerCopy!.position = CGPoint(x: 1.1 * bounds.width, y: -0.45 * bounds.height) // model value updated to be in synch with final animation frame
    
    mailButton.layer.addSublayer(planeLayerCopy!)
    
    // position animation
    let flyOutAnimation = CAKeyframeAnimation(keyPath: "position")
    flyOutAnimation.path = {
      let path = UIBezierPath()
      path.moveToPoint(CGPoint(x: CGRectGetMidX(mailButton.bounds), y: CGRectGetMidY(mailButton.bounds)))
      path.addQuadCurveToPoint(CGPoint(x: 1.1 * bounds.width, y: -0.45 * bounds.height), controlPoint: CGPoint(x: 0.6 * bounds.width, y: -0.3 * bounds.height))
      return path.CGPath
    }()
    
    // scale animation
    let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
    shrinkAnimation.toValue = CGFloat(0.2)
    
    // position + scale animations grouped
    let flyOutGroupAnimation = CAAnimationGroup()
    flyOutGroupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    flyOutGroupAnimation.duration = 0.5
    flyOutGroupAnimation.animations = [flyOutAnimation, shrinkAnimation]
    flyOutAnimation.fillMode = kCAFillModeForwards
    flyOutGroupAnimation.removedOnCompletion = false
    
    // add animation
    
    CATransaction.begin()
    CATransaction.setCompletionBlock { () -> Void in
      self.finishedFirstAnimation = true
      if (self.secondAnimationCompletion  != nil) {
        self.finishRefreshAnimation(self.secondAnimationCompletion)
        self.secondAnimationCompletion = nil
      }
    }
    planeLayerCopy?.addAnimation(flyOutGroupAnimation, forKey: AnimationKey.FlyOutAnimation)
    CATransaction.commit()
    
    // call refresh block
    onRefresh?()
  }
  
  /// This will cancel the refresh animation by fading out the flying paperplane and fading in 
  /// the original one on the button
  func cancelRefreshAnimation() {
    // cancel animations
    planeLayerCopy?.removeAllAnimations()
    
    // remove second layer from superlayer
    planeLayerCopy?.removeFromSuperlayer()
    
    planeLayerCopy = nil
    
    // synch model and show orinial paperplane
    mailButton.switchButtonState(animated: true)

    skipSecondAnimation = true
    
    onCancel?()
  }
  
  /// This will fly in the paperplane back to its original position
  func finishRefreshAnimation(onCompletion : (()->Void)? = nil) {
    // if the first animation is still in progress, "enqueue" the second animation
    guard finishedFirstAnimation else { secondAnimationCompletion = onCompletion; return }
    
    guard let plane = planeLayerCopy else { return }
    
    // change direction of plane
    plane.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)
    plane.position = CGPoint(x: 1.1 * bounds.width, y: -0.4 * bounds.height)
    
    // reset flag to start second animation
    self.skipSecondAnimation = false
    
    // position animation
    let flyInAnimation1 = CAKeyframeAnimation(keyPath: "position")
    flyInAnimation1.path = {
      let path = UIBezierPath()
      path.moveToPoint(CGPoint(x: 1.1 * bounds.width, y: -0.4 * bounds.height)) // start roughly where we left off
      path.addQuadCurveToPoint(CGPoint(x: -0.4 * bounds.width, y: 0.5 * mailButton.bounds.height), controlPoint: CGPoint(x: 0.4 * bounds.width, y: -0.8 * bounds.height))
      return path.CGPath
      }()
    
    // second step position animation
    let flyInAnimation2 = CABasicAnimation(keyPath: "position")
    flyInAnimation2.fromValue = NSValue(CGPoint: CGPoint(x: -0.4 * bounds.width, y: CGRectGetMidY(mailButton.bounds)))
    flyInAnimation2.toValue = NSValue(CGPoint: CGPoint(x: CGRectGetMidX(mailButton.bounds), y: CGRectGetMidY(mailButton.bounds)))
    flyInAnimation2.duration = 0.8
    flyInAnimation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    // scale animation
    let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
    shrinkAnimation.toValue = CGFloat(1.0)
    
    // position + scale animations grouped
    let flyInGroupAnimation = CAAnimationGroup()
    flyInGroupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    flyInGroupAnimation.duration = 0.5
    flyInGroupAnimation.animations = [flyInAnimation1, shrinkAnimation]
    flyInGroupAnimation.fillMode = kCAFillModeForwards
    flyInGroupAnimation.removedOnCompletion = false
    
    CATransaction.begin()
    CATransaction.setCompletionBlock { () -> Void in
      
      if !self.skipSecondAnimation {
        // second transaction
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
          if !self.skipSecondAnimation {
            // synch model and show orinial paperplane
            self.mailButton.switchButtonState(animated: false)
            
            onCompletion?()
          }
          
          // remove second layer from superlayer
          plane.removeFromSuperlayer()
        })
        // already fade out close button
        self.mailButton.showCLose(false, animated: true)
        
        plane.position = CGPoint(x: CGRectGetMidX(self.mailButton.bounds), y: CGRectGetMidY(self.mailButton.bounds)) // update model
        plane.transform = CATransform3DIdentity
        plane.addAnimation(flyInAnimation2, forKey: AnimationKey.FlyInAnimation2)
        
        CATransaction.commit()
      }
    }
    
    plane.addAnimation(flyInGroupAnimation, forKey: AnimationKey.FlyInAnimation1)
    CATransaction.commit()
  }
}

func delay(delay:Double, closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}