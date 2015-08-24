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
  let name: String
  let changeDate: NSDate!
  let huntDescription: String
  var checkpoints = [CheckPoint]()
  
  init(name: String, creatorName: String, huntDescription: String) {
    self.name = name
    self.changeDate = NSDate()
    self.huntDescription = huntDescription
    
    super.init()
  }
}

extension Hunt: PFSubclassing {
  static func parseClassName() -> String {
    return "Hunt"
  }
  
  override class func initialize() {
    struct Static {
      static var onceToken: dispatch_once_t = 0
    }
    dispatch_once(&Static.onceToken) {
      self.registerSubclass()
    }
  }
}

//extension Hunt: Printable {
//  override var description: String {
//    return "(\(name), \(creatorName), \(changeDate))"
//  }
//}
//extension Hunt: Hashable {
//  var hashValue: Int {
//    return "\(creatorName)\(changeDate)".hashValue
//  }
//}
//func == (lhs: Hunt, rhs: Hunt) -> Bool {
//  return (lhs.creatorName == rhs.creatorName) && (lhs.changeDate == rhs.changeDate)
//}
