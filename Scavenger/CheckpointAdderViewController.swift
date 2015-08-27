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
  var hunt: Hunt? {
    didSet {
      updateUI()
    }
  }
  private func updateUI() {
    huntName?.text = hunt?.name
    huntDetail?.text = hunt?.huntDescription
    navigationItem.title = hunt?.name
    tableView?.reloadData()
  }
  private var huntHasChanged = false
  
  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    huntName.delegate = self
    huntDetail.delegate = self
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneWasPressed")
    navigationItem.rightBarButtonItem = doneButton
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
    navigationItem.leftBarButtonItem = cancelButton
    
    tableView.registerNib(UINib(nibName: kCellNibName, bundle: nil), forCellReuseIdentifier: kCellIdentifier)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    saveHunt()
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
    
    if let hunt = hunt where huntHasChanged {
      huntHasChanged = false
      hunt.name = huntName.text
      hunt.huntDescription = huntDetail.text

      ParseService.saveHunt(hunt) { (succeeded, error) -> Void in
        if let error = error where !succeeded {
          let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
          self.presentViewController(alertController, animated: true, completion: nil)
        }
      }
    }
  }

  func doneWasPressed() {
    saveHunt()
    navigationController?.popViewControllerAnimated(true)
  }
  func cancelWasPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
}

//MARK: Table View Data Source
extension CheckpointAdderViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let hunt = hunt {
      return hunt.getCheckpoints().count
    }
    return 0
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
      hunt.addCheckpoint(checkpoint)
      hunt.saveInBackgroundWithBlock { (success, error) -> Void in
        if let error = error {
          let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Unable to save hunt", handler: nil)
          self.presentViewController(alertController, animated: true, completion: nil)
        }
      }
      tableView.reloadData()
    }
  }
}

extension CheckpointAdderViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(textField: UITextField) {
    huntHasChanged = true
  }
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    huntName.resignFirstResponder()
    huntDetail.resignFirstResponder()
    return true
  }
  
}