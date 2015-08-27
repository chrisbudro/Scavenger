//
//  CheckpointCell.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class CheckpointCell: UITableViewCell {

  // MARK: Public Properties
  var checkpoint: Checkpoint? {
    didSet {
      updateUI()
    }
  }

  // MARK: IBOutlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var checkpointImageView: UIImageView!

  // MARK: Private Helper Methods
  private func updateUI() {
    nameLabel?.text = checkpoint?.locationName
    detailLabel?.text = checkpoint?.clue
  }
}
