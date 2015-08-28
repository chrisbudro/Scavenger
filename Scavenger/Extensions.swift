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


//extension UIColor {
//  static func colorWithRedValue(#redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) -> UIColor {
//    return UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alpha)
//  }
//}