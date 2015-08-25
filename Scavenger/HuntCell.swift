//
//  HuntCell.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var huntLabel: UILabel!
  var hunt: Hunt! {
    didSet {
      updateUI()
    }
  }
  
  func updateUI() {
    huntLabel.text = hunt.name
  }
}
