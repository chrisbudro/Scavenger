//
//  CheckpointCreatorViewController.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import Parse

protocol CheckpointCreatorDelegate {
  func checkpointCreatorDidSaveCheckpoint(checkpoint: Checkpoint)
}

class CheckpointCreatorViewController: UIViewController {

  //MARK: Outlets
  @IBOutlet weak var locationNameTextField: UITextField!
  @IBOutlet weak var latitudeInputField: UITextField!
  @IBOutlet weak var longitudeInputField: UITextField!
  @IBOutlet weak var clueTextView: UITextView!
  
  //MARK: Properties
  var delegate: CheckpointCreatorDelegate?
  var checkpoint: Checkpoint? {
    didSet {
      updateUI()
    }
  }
  private func updateUI() {
    locationNameTextField?.text = checkpoint?.locationName
    latitudeInputField?.text = "/(checkpoint?.location.latitude)"
    longitudeInputField?.text = "/(checkpoint?.location.longitude)"
    clueTextView?.text = checkpoint?.clue
  }

  //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
      navigationItem.rightBarButtonItem = cancelButton
    }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    saveCheckpoint()
  }
  
  //MARK: Actions
  func saveCheckpoint() {
    
    //TODO: Check input validation
    if let checkpoint = checkpoint {
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
          //        self.navigationController?.popViewControllerAnimated(true)
        }
      }
    }
  }
  
  func cancelWasPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
}