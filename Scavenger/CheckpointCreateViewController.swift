//
//  CheckpointCreateViewController.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import Parse

protocol CheckpointCreationDelegate {
  func checkpointCreatorDidSaveCheckpoint(checkpoint: CheckPoint)
}

class CheckpointCreateViewController: UIViewController {

  //MARK: Outlets
  @IBOutlet weak var locationNameTextField: UITextField!
  @IBOutlet weak var latitudeInputField: UITextField!
  @IBOutlet weak var longitudeInputField: UITextField!
  @IBOutlet weak var clueTextView: UITextView!
  
  //MARK: Properties
  var delegate: CheckpointCreationDelegate?

  //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
      let saveButton = UIBarButtonItem(title: "Save Checkpoint", style: .Done, target: self, action: "saveCheckpointWasPressed")
      navigationItem.rightBarButtonItem = saveButton
      
      let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
      navigationItem.leftBarButtonItem = cancelButton
    }
  
  //MARK: Actions
  func saveCheckpointWasPressed() {
    let checkpoint = CheckPoint()
    
    //TODO: Check input validation
    checkpoint.locationName = locationNameTextField.text
    checkpoint.clue = clueTextView.text
    if let
      latitude = latitudeInputField.text.toDouble(),
      longitude = longitudeInputField.text.toDouble() {
        let geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        checkpoint.location = geoPoint
    }
    
    checkpoint.saveInBackgroundWithBlock { (success, error) -> Void in
      if let error = error {
        let alert = ErrorAlertHandler.errorAlertWithPrompt(error: "There was an error saving your checkpoint.  Please try again", handler: nil)
        self.presentViewController(alert, animated: true, completion: nil)
        
      } else if success {
        self.delegate?.checkpointCreatorDidSaveCheckpoint(checkpoint)
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
  
  func cancelWasPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
}