//
//  CheckpointPlayerViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//
//  Hunt User List View

import UIKit

class HuntPlayerViewController: UIViewController {
  
  // MARK: Public Properties
  var hunt: Hunt!
  var checkpoints: [Checkpoint]?
  
  // MARK: IBOutlets, IBActions
  @IBOutlet weak var tableView: UITableView!
  @IBAction func segmentedControl(sender: UISegmentedControl) {}
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    hunt.pinInBackground()
    navigationItem.title = hunt.name
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: "showPlayerMap")

    
    ParseService.fetchCheckpointsForHunt(hunt, sortOrder: .Distance) { (checkpoints, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Could not load checkpoints", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let checkpoints = checkpoints {
        self.checkpoints = checkpoints
        self.tableView.reloadData()
      }
    }
    
    tableView.registerNib(UINib(nibName: "CheckpointCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckpointCell")
    tableView.dataSource = self
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.rowHeight = 160
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showPlayerMap" {
      let vc = segue.destinationViewController as! PlayerMapViewController
      vc.hunt = hunt
    }
  }
  
  func showPlayerMap(){
    performSegueWithIdentifier("showPlayerMap", sender: self)
  }
}

// MARK: UITableViewDataSource
extension HuntPlayerViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return checkpoints != nil ? checkpoints!.count : 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CheckpointCell", forIndexPath: indexPath) as! CheckpointCell
    cell.checkpoint = checkpoints![indexPath.row]
    return cell
  }
}