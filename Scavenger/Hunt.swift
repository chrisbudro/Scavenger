//
//  Hunt.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation

class Hunt {
  let name: String
  let creatorName: String
  let changeDate: NSDate!
  let detail: String
  var clues = [CheckPoint]()
  
  init(name: String, creatorName: String, detail: String) {
    self.name = name
    self.creatorName = creatorName
    self.changeDate = NSDate()
    self.detail = detail
  }
}

extension Hunt: Printable {
  var description: String {
    return "(\(name), \(creatorName), \(changeDate))"
  }
}
extension Hunt: Hashable {
  var hashValue: Int {
    return "\(creatorName)\(changeDate)".hashValue
  }
}
func == (lhs: Hunt, rhs: Hunt) -> Bool {
  return (lhs.creatorName == rhs.creatorName) && (lhs.changeDate == rhs.changeDate)
}
