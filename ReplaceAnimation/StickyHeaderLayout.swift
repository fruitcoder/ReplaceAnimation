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
    
    var parallaxHeaderMinimumReferenceSize: CGSize = .zero
    var parallaxHeaderAlwaysOnTop: Bool = false
    var disableStickyHeaders: Bool = false
    
    override func prepare() {
        super.prepare()
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
        var frame = attributes?.frame
        frame!.origin.y += (self.parallaxHeaderReferenceSize?.height)!
        attributes?.frame = frame!
        
        print(attributes!.frame)
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        var attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        if attributes != nil && elementKind == PullToRefreshHeader.Kind {
            attributes = StickyHeaderLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        }
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var adjustedRec = rect
        adjustedRec.origin.y -= (self.parallaxHeaderReferenceSize?.height)!
        
        var allItems: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: adjustedRec)!
        
        let headers: NSMutableDictionary = NSMutableDictionary()
        let lastCells: NSMutableDictionary = NSMutableDictionary()
        var visibleParallaxHeader: Bool = false
        
        for attributes in allItems {
            var frame = attributes.frame
            frame.origin.y += (self.parallaxHeaderReferenceSize?.height)!
            attributes.frame = frame
            
            let indexPath = attributes.indexPath
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                headers.setObject(attributes, forKey: indexPath.section as NSCopying)
            } else {
                let currentAttribute = lastCells.object(forKey: indexPath.section)
                if currentAttribute == nil || indexPath.row > (currentAttribute as AnyObject).indexPath.row {
                    lastCells.setObject(attributes, forKey: indexPath.section as NSCopying)
                }
                if indexPath.item == 0 && indexPath.section == 0 {
                    visibleParallaxHeader = true
                }
            }
            
            attributes.zIndex = 1
        }
        
        if rect.minY <= 0 {
            visibleParallaxHeader = true
        }
        
        if self.parallaxHeaderAlwaysOnTop == true {
            visibleParallaxHeader = true
        }
        
        if visibleParallaxHeader && !CGSize.zero.equalTo(self.parallaxHeaderReferenceSize!) {
            let currentAttribute = StickyHeaderLayoutAttributes(forSupplementaryViewOfKind: PullToRefreshHeader.Kind, with: NSIndexPath(index: 0) as IndexPath)
            var frame = currentAttribute.frame
            frame.size.width = (self.parallaxHeaderReferenceSize?.width)!
            frame.size.height = (self.parallaxHeaderReferenceSize?.height)!
            
            let bounds = self.collectionView?.bounds
            let maxY = frame.maxY
            
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
            
            currentAttribute.frame = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: height)
            allItems.append(currentAttribute)
        }
        
        if !self.disableStickyHeaders {
            for obj in lastCells.keyEnumerator() {
                if let indexPath = (obj as AnyObject).indexPath {
                    let indexPAthKey = indexPath.section
                    
                    var header = headers[indexPAthKey]
                    if header == nil {
                        header = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section))
                        if let header:UICollectionViewLayoutAttributes = header as? UICollectionViewLayoutAttributes {
                            allItems.append(header)
                        }
                    }
                    
                    
                    self.updateHeaderAttributesForLastCellAttributes(attributes: header as! UICollectionViewLayoutAttributes, lastCellAttributes: lastCells[indexPAthKey] as! UICollectionViewLayoutAttributes)
                }
            }
        }
        
        return allItems
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            var frame = attributes.frame
            frame.origin.y += (self.parallaxHeaderReferenceSize?.height)!
            attributes.frame = frame
            return attributes
        } else {
            return nil
        }
    }
    
    override var collectionViewContentSize: CGSize {
        if self.collectionView?.superview == nil {
            return .zero
        }
        
        var size = super.collectionViewContentSize
        size.height += (self.parallaxHeaderReferenceSize?.height)!
        return size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    //MARK: Helper
    
    func updateHeaderAttributesForLastCellAttributes(attributes:UICollectionViewLayoutAttributes, lastCellAttributes: UICollectionViewLayoutAttributes) {
        let currentBounds = self.collectionView?.bounds
        attributes.zIndex = 1024
        attributes.isHidden = false
        
        var origin = attributes.frame.origin
        
        let sectionMaxY = lastCellAttributes.frame.maxY - attributes.frame.size.height
        var y = currentBounds!.maxY - (currentBounds?.size.height)! + (self.collectionView?.contentInset.top)!
        
        if self.parallaxHeaderAlwaysOnTop {
            y += self.parallaxHeaderMinimumReferenceSize.height
        }
        
        let maxY = min(max(y, attributes.frame.origin.y), sectionMaxY)
        
        origin.y = maxY
        
        attributes.frame = CGRect(x: origin.x, y:origin.y, width: attributes.frame.size.width, height: attributes.frame.size.width)
        print(attributes.frame)
    }
}
