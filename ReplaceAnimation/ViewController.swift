//
//  ViewController.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 05/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit
import MessageUI

private let reuseIdentifier = "Cell"

struct Joke {
  let question : String
  let answer : String
}

extension Joke {
  init?(json : [String : AnyObject]) {
    if let joke = json["joke"] {
      var separatedJoke = joke.componentsSeparatedByString("?")
      
      if separatedJoke.count == 2 {
        self.init(question: separatedJoke[0]+"?", answer: separatedJoke[1])
      } else if separatedJoke.count == 1 {
        separatedJoke = joke.componentsSeparatedByString(". ")  
        
        if separatedJoke.count == 2 {
          self.init(question: separatedJoke[0]+".", answer: separatedJoke[1])
        } else { return nil }
      } else { return nil }
    } else { return nil }
  }
}

class ViewController: UICollectionViewController {
  private var threshold : CGFloat = -95
  private var animateNewCell = false
  private var jokes = [
    Joke(question: "What's red and bad for your teeth?", answer: "A Brick."),
    Joke(question: "What do you call a chicken crossing the road?", answer: "Poultry in moton."),
    Joke(question: "Why did the fireman wear red, white, and blue suspenders?", answer: "To hold his pants up."),
    Joke(question: "How did Darth Vader know what Luke was getting for Christmas?", answer: "He felt his presents."),
    Joke(question: "My friend's bakery burned down last night.", answer: "Now his business is toast."),
    Joke(question: "What's funnier than a monkey dancing with an elephant?", answer: "Two monkeys dancing with an elephant.")
  ]
  private let emoticons = ["😂","😅","😆","😊","😬","🙃","🙂"]
  private let jokeService = JokeWebService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register cell classes
    let headerNib = UINib(nibName: "PullToRefreshHeader", bundle: NSBundle.mainBundle())
    self.collectionView!.registerNib(headerNib, forSupplementaryViewOfKind: PullToRefreshHeader.Kind, withReuseIdentifier: "header")
    
    let cellNib = UINib(nibName: "CollectionViewCell", bundle: NSBundle.mainBundle())
    self.collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    
    let screenBounds = UIScreen.mainScreen().bounds
    // setup layout
    if let layout: StickyHeaderLayout = self.collectionView?.collectionViewLayout as? StickyHeaderLayout {
      layout.parallaxHeaderReferenceSize = CGSizeMake(screenBounds.width, 0.56 * screenBounds.width)
      layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 60)
      layout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, layout.itemSize.height)
      layout.parallaxHeaderAlwaysOnTop = true
      layout.disableStickyHeaders = true
      self.collectionView?.collectionViewLayout = layout
      self.collectionView?.panGestureRecognizer.addTarget(self, action: Selector("handlePan:"))
    }
    
    threshold = -floor(0.3 * screenBounds.width)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
      return 1
  }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return jokes.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CollectionViewCell {
      cell.backgroundColor = UIColor.whiteColor()
      cell.titleLabel.text = jokes[indexPath.row].question
      cell.subtitleLabel.text = jokes[indexPath.row].answer
      cell.leftLabel.text = emoticons[random() % emoticons.count]
      
      return cell
    }
    
    return UICollectionViewCell()
  }

  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    if let header = collectionView.dequeueReusableSupplementaryViewOfKind(PullToRefreshHeader.Kind, withReuseIdentifier: "header", forIndexPath: indexPath) as? PullToRefreshHeader {
      header.onRefresh = { _ in
        self.jokeService.getJoke() { (joke) -> Void in
          NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            header.finishRefreshAnimation() { _ in
              if let joke = joke {
                self.animateNewCell = true
                self.jokes.insert(joke, atIndex: 0)
                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
              }
            }
          })
        }
      }
      header.onCancel = { _ in
        self.jokeService.cancelFetch()
      }
      header.onMailButtonPress = { _ in
        // write email
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Replace Animation")
        picker.setMessageBody("Any questions on the implementation?", isHTML: false)
        picker.setToRecipients(["alexhue91gmail.com"])
        
        self.presentViewController(picker, animated: true, completion: nil)
      }

      return header
    }
    
    return UICollectionReusableView()
  }
  
  override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if animateNewCell {
      let animation = CABasicAnimation(keyPath: "transform.scale")
      animation.toValue = 1.0
      animation.fromValue = 0.5
      animation.duration = 0.3
      
      cell.layer.addAnimation(animation, forKey: nil)

      animateNewCell = false
    }
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    if let layout: StickyHeaderLayout = self.collectionView?.collectionViewLayout as? StickyHeaderLayout {
      layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size.width, 60)
      layout.parallaxHeaderReferenceSize = CGSizeMake(size.width, 0.56 * size.width)
      layout.itemSize = CGSizeMake(size.width, layout.itemSize.height)
      
      coordinator.animateAlongsideTransition({ (context) -> Void in
        layout.invalidateLayout()
      }, completion: nil)
    }
  }

  func handlePan(pan : UIPanGestureRecognizer) {
    switch pan.state {
    case .Ended, .Failed, .Cancelled:
      
      if self.collectionView!.contentOffset.y <= threshold {
        
        // load items
        if let refreshHeader = collectionView!.visibleSupplementaryViewsOfKind(PullToRefreshHeader.Kind).first as? PullToRefreshHeader {
          if !refreshHeader.isLoading {
            refreshHeader.startRefreshAnimation()
          }
        }
      }
    default:
      break
    }
  }
}

extension ViewController : MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
