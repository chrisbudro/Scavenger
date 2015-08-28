//
//  MyHuntsViewController.swift
//  Scavenger
//
//  Created by Chris Budro on 8/27/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import Parse
import ParseUI

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
    super.viewDidLoad()
    let createHuntButton = UIBarButtonItem(title: "Create a Hunt", style: .Plain, target: self, action: "createHuntWasPressed")
    navigationItem.leftBarButtonItem = createHuntButton
    toggleLoginButton()
 
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: "MyHuntTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    loadPlayedHunts()
    loadCreatedHunts()
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
  
  func loadCreatedHunts() {
    ParseService.loadCurrentUserCreatedHunts { (hunts, error) in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let hunts = hunts {
        self.createdHunts = hunts
        self.tableView.reloadData()
      }
    }
  }
  
  func toggleLoginButton() {
    if let currentUser = PFUser.currentUser() {
      let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutWasPressed")
      navigationItem.rightBarButtonItem = logoutButton
    } else {
      let loginButton = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "loginWasPressed")
      navigationItem.rightBarButtonItem = loginButton
    }
  }
  
  //MARK: Actions
  func createHuntWasPressed() {
    if let currentUser = PFUser.currentUser() as? User {
      performSegueWithIdentifier("ShowHuntCreator", sender: nil)
    } else {
      let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Please login to create a hunt", handler: nil)
      presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
  func loginWasPressed() {
    presentLoginController()
  }
  
  func logoutWasPressed() {
    PFUser.logOut()
    toggleLoginButton()
  }
  
  func presentLoginController() {
    let loginController = PFLogInViewController()
    loginController.delegate = self
    loginController.signUpController?.delegate = self
    presentViewController(loginController, animated: true, completion: nil)
    
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as! CheckpointAdderViewController
    vc.hunt = Hunt()
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
      let huntCreatorController = storyboard?.instantiateViewControllerWithIdentifier("HuntCreatorViewController") as! CheckpointAdderViewController
      huntCreatorController.hunt = createdHunts[indexPath.row]
      navigationController?.pushViewController(huntCreatorController, animated: true)
    } else if indexPath.section == kPlayedHuntsSection {
      let huntPlayerController = storyboard?.instantiateViewControllerWithIdentifier("HuntPlayerViewController") as! HuntPlayerViewController
      huntPlayerController.hunt = playedHunts[indexPath.row]
      navigationController?.pushViewController(huntPlayerController, animated: true)
    }
  }
}

extension MyHuntsViewController: PFLogInViewControllerDelegate {
  
}

extension MyHuntsViewController: PFSignUpViewControllerDelegate {
  func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
    dismissViewControllerAnimated(true, completion: nil)
    if let currentUser = PFUser.currentUser() {
      println(currentUser)
    }
  }
}
