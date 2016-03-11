//
//  StickyHeaderLayout.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 05/03/16.
//
//  Based on Blackjacx : https://github.com/Blackjacx

import UIKit

class StickyHeaderLayout: UICollectionViewFlowLayout {
  var parallaxHeaderReferenceSize: CGSize? {
    didSet{
      self.invalidateLayout()
    }
  }
  
  var parallaxHeaderMinimumReferenceSize: CGSize = CGSizeZero
  var parallaxHeaderAlwaysOnTop: Bool = false
  var disableStickyHeaders: Bool = false
  
  override func prepareLayout() {
    super.prepareLayout()
  }
  
  override func initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = super.initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind, atIndexPath: elementIndexPath)
    var frame = attributes?.frame
    frame!.origin.y += (self.parallaxHeaderReferenceSize?.height)!
    attributes?.frame = frame!
    
    print(attributes!.frame)
    
    return attributes
  }
  
  override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    var attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
    if attributes != nil && elementKind == PullToRefreshHeader.Kind {
      attributes = StickyHeaderLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
    }
    
    return attributes
  }
  
   override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var adjustedRec = rect
    adjustedRec.origin.y -= (self.parallaxHeaderReferenceSize?.height)!
    
    var allItems: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(adjustedRec)!
    
    let headers: NSMutableDictionary = NSMutableDictionary()
    let lastCells: NSMutableDictionary = NSMutableDictionary()
    var visibleParallaxHeader: Bool = false
    
    for attributes in allItems {
      var frame = attributes.frame
      frame.origin.y += (self.parallaxHeaderReferenceSize?.height)!
      attributes.frame = frame
      
      let indexPath = attributes.indexPath
      if attributes.representedElementKind == UICollectionElementKindSectionHeader {
        headers.setObject(attributes, forKey: indexPath.section)
      } else {
        let currentAttribute = lastCells.objectForKey(indexPath.section)
        if currentAttribute == nil || indexPath.row > currentAttribute?.indexPath.row {
          lastCells.setObject(attributes, forKey: indexPath.section)
        }
        if indexPath.item == 0 && indexPath.section == 0 {
          visibleParallaxHeader = true
        }
      }
      
      attributes.zIndex = 1
    }
    
    if CGRectGetMinY(rect) <= 0 {
      visibleParallaxHeader = true
    }
    
    if self.parallaxHeaderAlwaysOnTop == true {
      visibleParallaxHeader = true
    }
    
    if visibleParallaxHeader && !CGSizeEqualToSize(CGSizeZero, self.parallaxHeaderReferenceSize!) {
      let currentAttribute = StickyHeaderLayoutAttributes(forSupplementaryViewOfKind: PullToRefreshHeader.Kind, withIndexPath: NSIndexPath(index: 0))
      var frame = currentAttribute.frame
      frame.size.width = (self.parallaxHeaderReferenceSize?.width)!
      frame.size.height = (self.parallaxHeaderReferenceSize?.height)!
      
      let bounds = self.collectionView?.bounds
      let maxY = CGRectGetMaxY(frame)
      
      var y = min(maxY - self.parallaxHeaderMinimumReferenceSize.height, (bounds?.origin.y)! + (self.collectionView?.contentInset.top)!)
      let height = max(0, -y + maxY)
      
      
      let maxHeight = self.parallaxHeaderReferenceSize!.height
      let minHeight = self.parallaxHeaderMinimumReferenceSize.height
      let progressiveness = (height - minHeight)/(maxHeight-minHeight)
      currentAttribute.progress = progressiveness
      
      currentAttribute.zIndex = 0
      
      if self.parallaxHeaderAlwaysOnTop {// && height <= self.parallaxHeaderMinimumReferenceSize.height {
        let insertTop = self.collectionView?.contentInset.top
        y = (self.collectionView?.contentOffset.y)! + insertTop!
        currentAttribute.zIndex = 2000
      }
      
      currentAttribute.frame = CGRectMake(frame.origin.x, y, frame.size.width, height)
      allItems.append(currentAttribute)
    }
    
    if !self.disableStickyHeaders {
      for obj in lastCells.keyEnumerator() {
        if let indexPath = obj.indexPath {
          let indexPAthKey = indexPath.section
          
          var header = headers[indexPAthKey]
          if header == nil {
            header = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: indexPath.section))
            if let header:UICollectionViewLayoutAttributes = header as? UICollectionViewLayoutAttributes {
              allItems.append(header)
            }
          }
          
          self.updateHeaderAttributesForLastCellAttributes(header as! UICollectionViewLayoutAttributes, lastCellAttributes: lastCells[indexPAthKey] as! UICollectionViewLayoutAttributes)
        }
      }
    }
    
    return allItems
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    if let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes {
      var frame = attributes.frame
      frame.origin.y += (self.parallaxHeaderReferenceSize?.height)!
      attributes.frame = frame
      return attributes
    } else {
      return nil
    }
  }
  
  override func collectionViewContentSize() -> CGSize {
    if self.collectionView?.superview == nil {
      return CGSizeZero
    }
    
    var size = super.collectionViewContentSize()
    size.height += (self.parallaxHeaderReferenceSize?.height)!
    return size
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  //MARK: Helper
  
  func updateHeaderAttributesForLastCellAttributes(attributes:UICollectionViewLayoutAttributes, lastCellAttributes: UICollectionViewLayoutAttributes) {
    let currentBounds = self.collectionView?.bounds
    attributes.zIndex = 1024
    attributes.hidden = false
    
    var origin = attributes.frame.origin
    
    let sectionMaxY = CGRectGetMaxY(lastCellAttributes.frame) - attributes.frame.size.height
    var y = CGRectGetMaxY(currentBounds!) - (currentBounds?.size.height)! + (self.collectionView?.contentInset.top)!
    
    if self.parallaxHeaderAlwaysOnTop {
      y += self.parallaxHeaderMinimumReferenceSize.height
    }
    
    let maxY = min(max(y, attributes.frame.origin.y), sectionMaxY)
    
    origin.y = maxY
    
    attributes.frame = CGRectMake(origin.x, origin.y, attributes.frame.size.width, attributes.frame.size.width)
    print(attributes.frame)
  }
}
