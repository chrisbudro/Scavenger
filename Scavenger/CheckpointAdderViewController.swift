//
//  CheckpointAdderViewController.swift
//  Scavenger
//
//  Created by Chris Budro on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import Parse

class CheckpointAdderViewController: UIViewController {
  
  //MARK: Constants
  let kCellIdentifier = "HuntDetailCell"
  let kCellNibName = "HuntDetailCell"
  
  //MARK: Outlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  var hunt: Hunt!
  
  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    
    let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButtonWasPressed")
    navigationItem.rightBarButtonItem = saveButton
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
    navigationItem.leftBarButtonItem = cancelButton
    
    tableView.registerNib(UINib(nibName: kCellNibName, bundle: nil), forCellReuseIdentifier: kCellIdentifier)
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowCheckpointCreate" {
      let vc = segue.destinationViewController as! CheckpointCreatorViewController
      vc.delegate = self
    }
  }
  
  //MARK: Actions
  @IBAction func addCheckpointWasPressed() {
    performSegueWithIdentifier("ShowCheckpointCreate", sender: nil)
  }
  
  func saveButtonWasPressed() {
    ParseService.saveHunt(hunt) { (succeeded, error) -> Void in
      if let error = error where !succeeded {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if succeeded {
        self.navigationController?.popToRootViewControllerAnimated(true)
      }
    }
  }
  
  func cancelWasPressed() {

    hunt.deleteEventually()
    navigationController?.popViewControllerAnimated(true)
  }
}

//MARK: Table View Data Source
extension CheckpointAdderViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hunt.checkpoints.count
  }

  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! CheckpointCell
    let checkpoint = hunt.checkpoints[indexPath.row]
    cell.checkPoint = checkpoint
    
    return cell
  }
}

//MARK: Table View Delegate
extension CheckpointAdderViewController: UITableViewDelegate {
  
  
}

//MARK: Checkpoint Creation Delegate
extension CheckpointAdderViewController: CheckpointCreatorDelegate {
  func checkpointCreatorDidSaveCheckpoint(checkpoint: Checkpoint) {
    
    hunt.checkpoints.append(checkpoint)
    hunt.saveInBackgroundWithBlock { (success, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Unable to save hunt", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      }
    }
    tableView.reloadData()
  }
}
