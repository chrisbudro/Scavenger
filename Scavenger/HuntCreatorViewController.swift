//
//  HuntCreatorViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntCreatorViewController: UIViewController {
  
  //MARK: Outlets
  @IBOutlet weak var huntName: UITextField!
  @IBOutlet weak var huntDetail: UITextField!
  
  
  //MARK: Lifecyle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Hunt Creator"
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed")
    
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowCheckpointAdder" {
      let checkpointAdderVC = segue.destinationViewController as! CheckpointAdderViewController
      if let hunt = sender as? Hunt {
        checkpointAdderVC.hunt = hunt
      }
    }
  }
  
  //MARK: Actions
  @IBAction func buildHuntWasPressed() {
    
    let hunt = Hunt()
    hunt.name = huntName.text
    hunt.huntDescription = huntDetail.text
    
    hunt.saveInBackgroundWithBlock { (succeeded, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Hunt could not be saved.  Please try again.", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if succeeded {
        self.performSegueWithIdentifier("ShowCheckpointAdder", sender: hunt)
      }
    }
  }
  
  func cancelWasPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
}
