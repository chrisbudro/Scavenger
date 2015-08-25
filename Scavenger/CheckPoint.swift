//
//  CheckPoint.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

class CheckPoint: PFObject {
  @NSManaged var locationName: String
  @NSManaged var location: PFGeoPoint
  @NSManaged var clue: String
}

extension CheckPoint: PFSubclassing {
  static func parseClassName() -> String {
    return "CheckPoint"
  }
}


extension CheckPoint: Printable {
  override var description: String {
    return "(\(locationName),\(clue))"
  }
}
extension CheckPoint: Hashable {
  override var hashValue: Int {
    return "\(locationName)".hashValue
  }
}

func == (lhs: CheckPoint, rhs: CheckPoint) -> Bool {
  return (lhs.locationName == rhs.locationName) && (lhs.location == rhs.location)
}







