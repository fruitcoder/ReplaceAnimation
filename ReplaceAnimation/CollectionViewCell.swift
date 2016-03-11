//
//  CollectionViewCell.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 07/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var leftImage: UIImageView!
  @IBOutlet weak var leftLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
