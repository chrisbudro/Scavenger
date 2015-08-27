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
  let kNumberOfSections = 2
  let kCellIdentifier = "MyHuntCell"
  
  
  //MARK: Outlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  var createdHunts = [Hunt]()
  var playedHunts = [Hunt]()
  
  override func viewDidLoad() {
    let createHuntButton = UIBarButtonItem(title: "Create a Hunt", style: .Plain, target: self, action: "createHuntWasPressed")
    navigationItem.leftBarButtonItem = createHuntButton
    setLoginButton()
    
    
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
  
  func setLoginButton() {
    let loginButton = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "loginWasPressed")
    navigationItem.rightBarButtonItem = loginButton
  }
  
  //MARK: Actions
  func createHuntWasPressed() {
    performSegueWithIdentifier("ShowHuntCreator", sender: nil)
  }
  
  func loginWasPressed() {
    
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

  }
}

//MARK: Table View Data Source
extension MyHuntsViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return kNumberOfSections
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == kCreatedHuntsSection && createdHunts.count > 0 {
      return "Hunts I've Created"
    } else if section == kPlayedHuntsSection && playedHunts.count > 0 {
      return "Hunts in Progress"
    }
    return nil
  }
  
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
      hunt = createdHunts[indexPath.row]
    } else if indexPath.section == kPlayedHuntsSection {
      hunt = playedHunts[indexPath.row]
    }
    cell.huntNameLabel.text = hunt?.name
    
    return cell
  }
}

extension MyHuntsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == kCreatedHuntsSection {
      
    } else if indexPath.section == kPlayedHuntsSection {
      let huntPlayerController = storyboard?.instantiateViewControllerWithIdentifier("HuntPlayerViewController") as! HuntPlayerViewController
      huntPlayerController.hunt = playedHunts[indexPath.row]
      navigationController?.pushViewController(huntPlayerController, animated: true)
    }
  }
}
