//
//  MyHuntTableViewCell.swift
//  Scavenger
//
//  Created by Chris Budro on 8/27/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class MyHuntTableViewCell: UITableViewCell {

  @IBOutlet weak var huntNameLabel: UILabel!
  @IBOutlet weak var huntImageView: UIImageView!
  
  var hunt: Hunt? {
    didSet {
      updateUI()
    }
  }
  
  func updateUI() {
    huntNameLabel.text = hunt?.name
  }
}
