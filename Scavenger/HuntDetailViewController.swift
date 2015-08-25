//
//  HuntDetailViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//
//  Hunt User List View

import UIKit

class HuntDetailViewController: UIViewController {
  
  let navigationTitle = "Hunt (User List View)"
  
  // MARK: Public Properties
  var hunt: Hunt? {
    didSet {
      updateUI()
    }
  }
  
  // MARK: IBOutlets, IBActions
  @IBOutlet weak var huntNameLabel: UILabel!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerNib(UINib(nibName: "HuntDetailCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "HuntDetailCell")
      tableView.dataSource = self
      //tableView.estimatedRowHeight = tableView.rowHeight
      //tableView.rowHeight = UITableViewAutomaticDimension
      tableView.rowHeight = 160
    }
  }
  @IBAction func segmentedControl(sender: UISegmentedControl) {}
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = navigationTitle
    
    // stuff some data in to test
    hunt = Hunt(name: "Pike Place Market, Seattle", creatorName: "mdavis", huntDescription: "A way cool hunt through Pike Place Market")
    let cp1 = CheckPoint(locationName: "Checkpoint 1", detail: "Enter the market from the NE corner and look for a vender selling local brands of honey. Find the fish painting nearby.", location: 180.0)
    let cp2 = CheckPoint(locationName: "Checkpoint 2", detail: "Choose the staircase the takes you one level below the public restrooms and find exit that faces Puget Sound. Locate a unique but very ugly statue.", location: -180.0)
    let cp3 = CheckPoint(locationName: "Checkpoint 3", detail: "Enter the market from the NE corner and look for a vender selling local brands of honey. Find the fish painting nearby.", location: 180.0)
    let cp4 = CheckPoint(locationName: "Checkpoint 4", detail: "Choose the staircase the takes you one level below the public restrooms and find exit that faces Puget Sound. Locate a unique but very ugly statue.", location: -180.0)
    hunt!.checkpoints += [cp1, cp2, cp3, cp4]
  }
  
  // MARK: Private Helper Methods
  private func updateUI() {
    huntNameLabel?.text = hunt?.name
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension HuntDetailViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = hunt?.checkpoints.count {
      return count
    }
    return 0
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("HuntDetailCell", forIndexPath: indexPath) as! HuntDetailCell
    cell.checkPoint = hunt?.checkpoints[indexPath.row]
    return cell
  }
}