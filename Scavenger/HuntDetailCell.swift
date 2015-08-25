//
//  HuntDetailCell.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntDetailCell: UITableViewCell {

  // MARK: Public Properties
  var checkPoint: CheckPoint? {
    didSet {
      updateUI()
    }
  }

  // MARK: IBOutlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!

  // MARK: Private Helper Methods
  private func updateUI() {
    nameLabel?.text = checkPoint?.locationName
    detailLabel?.text = checkPoint?.detail
  }
}
