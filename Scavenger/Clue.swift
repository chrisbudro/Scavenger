//
//  Clue.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

struct CheckPoint {
  let locationName: String
  let location: PFGeoPoint?
  let detail: String
  
  init(locationName: String, detail: String, location: CLLocation?) {
    self.locationName = locationName
    self.location = location
    self.detail = detail
  }
}

extension CheckPoint: Printable {
  var description: String {
    return "(\(locationName),\(location),\(detail))"
  }
}
extension CheckPoint: Hashable {
  var hashValue: Int {
    return "\(locationName)\(location)".hashValue
  }
}
func == (lhs: CheckPoint, rhs: CheckPoint) -> Bool {
  return (lhs.locationName == rhs.locationName) && (lhs.location == rhs.location)
}