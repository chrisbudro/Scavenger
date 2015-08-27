//
//  User.swift
//  Scavenger
//
//  Created by Chris Budro on 8/27/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import Parse

class User: PFUser {
  @NSManaged var createdHunts: [Hunt]?
  
  func addCreatedHunt(hunt: Hunt) {
    if createdHunts == nil {
      createdHunts = [Hunt]()
    }
    createdHunts!.append(hunt)
  }
}

extension User: PFSubclassing {
  
}