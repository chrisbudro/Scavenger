//
//  Hunt.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

class Hunt: PFObject {
  @NSManaged var name: String
  @NSManaged var huntDescription: String
  @NSManaged private var checkpoints: [Checkpoint]?
  
//  override init() {
//    super.init()
//  }
  
  func getCheckpoints() -> [Checkpoint] {
    if let checkpoints = checkpoints {
      return checkpoints
    } else {
      return [Checkpoint]()
    }
//    return (checkpoints != nil) ? [Checkpoint]() : checkpoints
  }
  
  func addCheckpoint(checkpoint: Checkpoint) {
    checkpoints?.append(checkpoint)
  }
}

extension Hunt: PFSubclassing {
  static func parseClassName() -> String {
    return "Hunt"
  }
}

extension Hunt: Printable {
  override var description: String {
    return "(\(name), \(huntDescription))"
  }
}
extension Hunt: Hashable {
  override var hashValue: Int {
    return "\(name)\(huntDescription)".hashValue
  }
}
func == (lhs: Hunt, rhs: Hunt) -> Bool {
  return (lhs.name == rhs.name) && (lhs.huntDescription == rhs.huntDescription)
}
