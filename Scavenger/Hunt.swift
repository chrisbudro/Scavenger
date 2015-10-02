//
//  Hunt.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

enum HuntStyle {
  case AllCheckpoints
  case CurrentCheckpoint
}

class Hunt: PFObject {
  @NSManaged var name: String?
  @NSManaged var huntDescription: String?
  @NSManaged private var checkpoints: [Checkpoint]?
  var huntStyle: HuntStyle?
  var huntImage: UIImage?

  func getCheckpoints() -> [Checkpoint] {
    if checkpoints == nil {
      return [Checkpoint]()
    }
    return checkpoints!
  }
  
  func addCheckpoint(checkpoint: Checkpoint) {
    if checkpoints == nil {
      checkpoints = [Checkpoint]()
    }
    checkpoints!.append(checkpoint)
  }
  func deleteCheckpoint(atIndex: Int) -> Checkpoint? {
    if checkpoints == nil || atIndex < 0 || atIndex >= checkpoints!.count {
      return nil
    }
    return checkpoints!.removeAtIndex(atIndex)
  }
}

extension Hunt: PFSubclassing {
  static func parseClassName() -> String {
    return "Hunt"
  }
}

// mark - CustomStringConvertible
extension Hunt {
  override var description: String {
    return "(\(name), \(huntDescription))"
  }
}

// mark - Hashable
extension Hunt {
  override var hashValue: Int {
    return "\(name)\(huntDescription)".hashValue
  }
}
func == (lhs: Hunt, rhs: Hunt) -> Bool {
  return (lhs.name == rhs.name) && (lhs.huntDescription == rhs.huntDescription)
}
