//
//  MyHuntsViewController.swift
//  Scavenger
//
//  Created by Chris Budro on 8/27/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class MyHuntsViewController: UIViewController {
  
  //MARK: Constants
  let kCreatedHuntsSection = 0
  let kPlayedHuntsSection = 1
  let kCellIdentifier = "MyHuntCell"
  
  //MARK: Outlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  var createdHunts = [Hunt]()
  var playedHunts = [Hunt]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: "MyHuntTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
    
    loadPlayedHunts()
  }
  
  //MARK: Helper Methods
  func loadPlayedHunts() {
    ParseService.loadStoredHunts { (playedHunts, error) -> Void in
      if let error = error {
        //TODO: Error Alert
      } else if let playedHunts = playedHunts {
        self.playedHunts = playedHunts
        self.tableView.reloadData()
      }
    }
  }
  
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
}

extension MyHuntsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == kCreatedHuntsSection {
      return createdHunts.count
    } else if section == kPlayedHuntsSection {
      return playedHunts.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! MyHuntTableViewCell
    var hunt: Hunt?
    if indexPath.section == kCreatedHuntsSection {
      let hunt = createdHunts[indexPath.row]
    } else if indexPath.section == kPlayedHuntsSection {
      let hunt = playedHunts[indexPath.row]
    }
    cell.hunt = hunt
    
    return cell
  }
}

extension MyHuntsViewController: UITableViewDelegate {
  
}
