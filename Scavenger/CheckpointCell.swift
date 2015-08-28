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
      updateTextUI()
    }
  }
  var clueImage: UIImage? {
    didSet {
      updateImageUI()
    }
  }
  var hideNameAndImage = false {
    didSet {
      updateTextUI()
      updateImageUI()
    }
  }
  
  // MARK: IBOutlets
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var detailLabel: UILabel!
  @IBOutlet private weak var checkpointImageView: UIImageView!
  
  // MARK: Private Helper Methods
  private func updateTextUI() {
    if hideNameAndImage {
      nameLabel?.text = nil
    } else {
      nameLabel?.text = checkpoint?.locationName
    }
    detailLabel?.text = checkpoint?.clue
  }
  private func updateImageUI() {
    if hideNameAndImage {
      //checkpointImageView?.image = nil
    } else {
      checkpointImageView?.image = clueImage
    }
  }
}
