//
//  Extensions.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation

extension String {
  func toDouble() -> Double? {
    return NSNumberFormatter().numberFromString(self)?.doubleValue
  }
}