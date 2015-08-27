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
  
  @IBOutlet weak var huntName: UITextField!
  @IBOutlet weak var huntDetail: UITextField!
  
  //MARK: Constants
  let kCellIdentifier = "CheckpointCell"
  let kCellNibName = "CheckpointCell"
  
  //MARK: Outlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  var hunt: Hunt!
  var checkpointsFetched = false

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ParseService.fetchCheckpointsForHunt(hunt, sortOrder: .Distance) { (checkpoints, error) in
      self.checkpointsFetched = true
      self.updateUI()
    }
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    huntName.delegate = self
    huntDetail.delegate = self
    
//    let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButtonWasPressed")
//    navigationItem.rightBarButtonItem = saveButton
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
    navigationItem.rightBarButtonItem = cancelButton
    
    tableView.registerNib(UINib(nibName: kCellNibName, bundle: nil), forCellReuseIdentifier: kCellIdentifier)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    saveHunt()
  }
  
  //MARK: Helper Methods
  private func updateUI() {
    huntName?.text = hunt?.name
    huntDetail?.text = hunt?.huntDescription
    navigationItem.title = hunt?.name
    tableView?.reloadData()
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowCheckpointCreate", let vc = segue.destinationViewController as? CheckpointCreatorViewController {
      vc.delegate = self
      vc.checkpoint = Checkpoint()
    } else if segue.identifier == "ShowCheckpointModify" {
      if let vc = segue.destinationViewController as? CheckpointCreatorViewController, indexPath = tableView.indexPathForSelectedRow(), hunt = hunt {
        vc.delegate = self
        vc.checkpoint = hunt.getCheckpoints()[indexPath.row]
      }
    }
  }
  
  //MARK: Actions
  @IBAction func addCheckpointWasPressed() {
    performSegueWithIdentifier("ShowCheckpointCreate", sender: nil)
  }
  
  private func saveHunt() {
    
    if let hunt = hunt {
      hunt.name = huntName.text
      hunt.huntDescription = huntDetail.text

      ParseService.saveHunt(hunt) { (succeeded, error) -> Void in
        if let error = error where !succeeded {
          let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
          self.presentViewController(alertController, animated: true, completion: nil)
        } else if succeeded {
          ParseService.assignCreatedHuntToCurrentUser(hunt: hunt)
        }
      }
    }
  }
  
  func cancelWasPressed() {

//    hunt.deleteEventually()
    navigationController?.popViewControllerAnimated(true)
  }
}

//MARK: Table View Data Source
extension CheckpointAdderViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return checkpointsFetched ? hunt.getCheckpoints().count : 0
  }

  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! CheckpointCell
    if let hunt = hunt {
      let checkpoint = hunt.getCheckpoints()[indexPath.row]
      cell.checkpoint = checkpoint
    }
    return cell
  }
}

//MARK: Table View Delegate
extension CheckpointAdderViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     performSegueWithIdentifier("ShowCheckpointModify", sender: nil)
  }
  
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {
      if let hunt = hunt {
        hunt.deleteCheckpoint(indexPath.row)
        saveHunt()
      }
      let indexPaths = [indexPath]
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
  }

  
}

//MARK: Checkpoint Creation Delegate
extension CheckpointAdderViewController: CheckpointCreatorDelegate {
  func checkpointCreatorDidSaveCheckpoint(checkpoint: Checkpoint) {
    if let hunt = hunt {
      ParseService.addCheckpointToHunt(hunt, checkpoint: checkpoint) { (success, error) in
        if let error = error {
          let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Unable to save hunt", handler: nil)
          self.presentViewController(alertController, animated: true, completion: nil)
        } else if success {
          self.tableView.reloadData()
        }
      }
    }
  }
}

extension CheckpointAdderViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    huntName.resignFirstResponder()
    huntDetail.resignFirstResponder()
    return true
  }
  
}