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
            var separatedJoke = joke.components(separatedBy: "?")
            
            if separatedJoke.count >= 2 {
                self.init(question: separatedJoke[0]+"?", answer: separatedJoke[1])
            } else if separatedJoke.count == 1 {
                separatedJoke = joke.components(separatedBy: ". ")
                
                if separatedJoke.count >= 2 {
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
        let headerNib = UINib(nibName: "PullToRefreshHeader", bundle: Bundle.main)
        self.collectionView!.register(headerNib, forSupplementaryViewOfKind: PullToRefreshHeader.Kind, withReuseIdentifier: "header")
        
        let cellNib = UINib(nibName: "CollectionViewCell", bundle: Bundle.main)
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
        
        let screenBounds = UIScreen.main.bounds
        // setup layout
        if let layout: StickyHeaderLayout = self.collectionView?.collectionViewLayout as? StickyHeaderLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: screenBounds.width, height: 0.56 * screenBounds.width)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = true
            layout.disableStickyHeaders = true
            self.collectionView?.collectionViewLayout = layout
            
            self.collectionView?.panGestureRecognizer.addTarget(self, action: #selector(ViewController.handlePan(pan:)))
        }
        
        threshold = -floor(0.3 * screenBounds.width)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jokes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
            cell.backgroundColor = UIColor.white
            cell.titleLabel.text = jokes[indexPath.row].question
            cell.subtitleLabel.text = jokes[indexPath.row].answer
            cell.leftLabel.text = emoticons[Int(arc4random()) % emoticons.count]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: PullToRefreshHeader.Kind, withReuseIdentifier: "header", for: indexPath) as? PullToRefreshHeader {
            header.onRefresh = {
                self.jokeService.getJoke() { (joke) -> Void in
                    DispatchQueue.main.async {
                        header.finishRefreshAnimation() {
                            if let joke = joke {
                                self.animateNewCell = true
                                self.jokes.insert(joke, at: 0)
                                self.collectionView?.insertItems(at: [IndexPath(item: 0, section: 0)])
                            }
                        }
                    }
                }
            }
            header.onCancel = {
                self.jokeService.cancelFetch()
            }
            
            header.onMailButtonPress = {
                // write email
                guard MFMailComposeViewController.canSendMail() else {
                    return
                }
                
                let picker = MFMailComposeViewController()
                picker.mailComposeDelegate = self
                picker.setSubject("Replace Animation")
                picker.setMessageBody("Any questions on the implementation?", isHTML: false)
                picker.setToRecipients(["alexhue91gmail.com"])
                
                self.present(picker, animated: true, completion: nil)
            }
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if animateNewCell {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 1.0
            animation.fromValue = 0.5
            animation.duration = 0.3
            
            cell.layer.add(animation, forKey: nil)
            
            animateNewCell = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let layout: StickyHeaderLayout = self.collectionView?.collectionViewLayout as? StickyHeaderLayout {
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: size.width, height: 60)
            layout.parallaxHeaderReferenceSize = CGSize(width: size.width, height: 0.56 * size.width)
            layout.itemSize = CGSize(width: size.width, height: layout.itemSize.height)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                layout.invalidateLayout()
            }, completion: nil)
        }
    }
    
    @objc func handlePan(pan : UIPanGestureRecognizer) {
        switch pan.state {
        case .ended, .failed, .cancelled:
            
            if self.collectionView!.contentOffset.y <= threshold {
                
                // load items
                if let refreshHeader = collectionView!.visibleSupplementaryViews(ofKind: PullToRefreshHeader.Kind).first as? PullToRefreshHeader {
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
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
