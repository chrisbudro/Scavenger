//
//  Checkpoint.swift
//  Scavenger
//
//  Created by mike davis on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse
import GoogleMaps

class Checkpoint: PFObject {
  @NSManaged var locationName: String?
  @NSManaged var location: PFGeoPoint?
  @NSManaged var clue: String?
  @NSManaged var placeID: String?
  @NSManaged var photo: PFFile?
  
  var completed = false
  var marker: GMSMarker?
  var circleOverlay: GMSCircle?
  
  var coreLocation: CLLocation? {
    if let location = location {
      return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    return nil
  }

  func setMarker() {
    if let coreLocation = coreLocation {
      marker = GMSMarker(position: coreLocation.coordinate)
      marker?.title = locationName
    }
  }
}

extension Checkpoint: PFSubclassing {
  static func parseClassName() -> String {
    return "Checkpoint"
  }
}

// mark - CustomStringConvertible
extension Checkpoint {
  override var description: String {
    return "(\(locationName),\(clue))"
  }
}

// mark - Hashable
extension Checkpoint {
  override var hashValue: Int {
    return "\(locationName)".hashValue
  }
}

func == (lhs: Checkpoint, rhs: Checkpoint) -> Bool {
  return (lhs.locationName == rhs.locationName) && (lhs.location == rhs.location)
}







