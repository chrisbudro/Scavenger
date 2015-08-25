//
//  Checkpoint.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

class Checkpoint: PFObject {
  @NSManaged var locationName: String
  @NSManaged var location: PFGeoPoint
  @NSManaged var clue: String
  
  var coreLocation: CLLocation {
    return CLLocation(latitude: location.latitude, longitude: location.longitude)
  }
}

extension Checkpoint: PFSubclassing {
  static func parseClassName() -> String {
    return "Checkpoint"
  }
}


extension Checkpoint: Printable {
  override var description: String {
    return "(\(locationName),\(clue))"
  }
}
extension Checkpoint: Hashable {
  override var hashValue: Int {
    return "\(locationName)".hashValue
  }
}

func == (lhs: Checkpoint, rhs: Checkpoint) -> Bool {
  return (lhs.locationName == rhs.locationName) && (lhs.location == rhs.location)
}







