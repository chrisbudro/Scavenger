//
//  ErrorAlertHandler.swift
//  Scavenger
//
//  Created by Chris Budro on 8/25/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class ErrorAlertHandler {
  class func errorAlertWithPrompt(#error: String, handler: (() -> Void)?) -> UIAlertController {
    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
      handler?()
    })
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in })
    return alertController
  }
  
  class func errorAlertWithoutPrompt(#error: String, handler: (() -> Void)?) -> UIAlertController {
    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)

    return alertController
  }
}