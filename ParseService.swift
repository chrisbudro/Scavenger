//
//  ParseService.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class ParseService {
  
  enum SortOrder {
    case Distance
  }

  class func saveHunt(hunt: Hunt, completion: (Bool, error: String?) -> Void) {
    hunt.saveInBackgroundWithBlock { (succeeded, error) in
      if let error = error where !succeeded {
        completion(false, error: error.description)
      } else if succeeded {
        completion(true, error: nil)
      }
    }
  }
  
  class func loadHunts(completion: (hunts: [Hunt]?, error: String?) -> Void) {
    if let query = Hunt.query() {
      query.findObjectsInBackgroundWithBlock { (hunts, error) in
        if let error = error {
          completion(hunts: nil, error: error.description)
        } else {
          if let hunts = hunts as? [Hunt] {
            completion(hunts: hunts, error: nil)
          }
        }
      }
    }
  }
  
  class func loadHuntsWithTags(tags: [String], completion: (hunts: [Hunt]?, error: String?) -> Void) {
    if let query = Hunt.query() {
      query.whereKey("tags", containedIn: tags)
      query.findObjectsInBackgroundWithBlock { (hunts, error) -> Void in
        if let error = error {
          completion(hunts: nil, error: error.description)
        } else if let hunts = hunts as? [Hunt] {
          completion(hunts: hunts, error: nil)
        }
      }
    }
  }
  
  class func deleteHunt(hunt: Hunt, completion: (Bool, error: String?) -> Void) {
    hunt.deleteInBackgroundWithBlock { (succeeded, error) in
      if let error = error where !succeeded {
        completion(false, error: error.description)
      } else if succeeded {
        completion(true, error: nil)
      }
    }
  }
  
  class func fetchCheckpointsForHunt(hunt: Hunt, sortOrder: SortOrder, completion: ([Checkpoint]?, error: String?) -> Void) {
    PFObject.fetchAllIfNeededInBackground(hunt.getCheckpoints()) { (checkpoints, error) -> Void in
      if let error = error {
        completion(nil, error: error.description)
      } else if let checkpoints = checkpoints as? [Checkpoint] {

        switch sortOrder {
          case .Distance:
            //TODO: Replace Current location with actual current location
            let currentLocation = PFGeoPoint(latitude: 47.623390, longitude: -122.336098) //Placeholder current location
            let sortedCheckpoints = self.checkpointsByDistance(checkpoints, currentLocation: currentLocation)
            completion(sortedCheckpoints, error: nil)
          default:
            completion(checkpoints, error: nil)
        }
      }
    }
  }

  class func checkpointsByDistance(checkpoints: [Checkpoint], currentLocation: PFGeoPoint) -> [Checkpoint]? {
    let sortedCheckpoints = sorted(checkpoints, { (checkpoint1: Checkpoint, checkpoint2: Checkpoint) -> Bool in
      return checkpoint1.location.distanceInMilesTo(currentLocation) < checkpoint2.location.distanceInMilesTo(currentLocation)
    })
    return sortedCheckpoints
  }
}