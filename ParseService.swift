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

typealias HuntCompletionHandler = (hunts: [Hunt]?, error: String?) -> Void

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
  
  class func loadHunts(completion: HuntCompletionHandler) {
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
  
  class func loadHuntsWithTags(tags: [String], completion: HuntCompletionHandler) {
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
  
  class func loadStoredHunts(#completion: HuntCompletionHandler) {
    if let query = Hunt.query() {
      query.fromLocalDatastore()
      query.findObjectsInBackgroundWithBlock { (hunts, error) in
        if let error = error {
          completion(hunts: nil, error: error.description)
        } else if let hunts = hunts as? [Hunt] {
          println(hunts.count)
          completion(hunts: hunts, error: nil)
        }
      }
    }
  }
  
  class func loadCurrentUserCreatedHunts(#completion: HuntCompletionHandler) {
    if let currentUser = PFUser.currentUser() as? User {
      PFObject.fetchAllIfNeededInBackground(currentUser.createdHunts) { (createdHunts, error) in
        if let error = error {
          completion(hunts: nil, error: error.description)
        } else if let createdHunts = createdHunts as? [Hunt] {
          completion(hunts: createdHunts, error: nil)
        }
      }
    } else {
      completion(hunts: nil, error: "Please login to view your created hunts")
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
  
  class func addCheckpointToHunt(hunt: Hunt?, checkpoint: Checkpoint, completion: (Bool, error: String?) -> Void) {
    if let hunt = hunt {
      hunt.addUniqueObject(checkpoint, forKey: "checkpoints")
      hunt.saveInBackgroundWithBlock { (success, error) -> Void in
        if let error = error {
          completion(false, error: error.description)
        } else if success {
          completion(true, error: nil)
        }
      }
    }
  }
  
  class func assignCreatedHuntToCurrentUser(#hunt: Hunt) {
    if let currentUser = PFUser.currentUser() as? User {
      currentUser.addUniqueObject(hunt, forKey: "createdHunts")
      currentUser.saveInBackground()
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
      if let location1 = checkpoint1.location, location2 = checkpoint2.location {
        return location1.distanceInMilesTo(currentLocation) < location2.distanceInMilesTo(currentLocation)
      } else if checkpoint1.location == nil {
        return false
      }
      return true
    })
    return sortedCheckpoints
  }
  
  class func imageForHunt(hunt: Hunt, completion: (UIImage?, error: String?) -> Void) {
    
    if let firstCheckpoint = hunt.getCheckpoints().first {
      imageForCheckpoint(firstCheckpoint) { (image, error) -> Void in
        completion(image, error: error)
      }
    }
  }

  class func imageForCheckpoint(checkpoint: Checkpoint, completion: (UIImage?, error: String?) -> Void) {
    checkpoint.fetchIfNeededInBackgroundWithBlock { (checkpoint, error) in
      if let
        checkpoint = checkpoint as? Checkpoint,
        imageFile = checkpoint.photo {
        imageFile.getDataInBackgroundWithBlock { (data, error) in
          if let error = error {
            completion(nil, error: error.description)
          } else if let
            data = data,
            image = UIImage(data: data) {
              completion(image, error: nil)
          }
        }
      } else {
        completion(nil, error: "No image available")
      }
    }
  }
}