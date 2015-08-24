//
//  ParseService.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

class ParseService {

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
}