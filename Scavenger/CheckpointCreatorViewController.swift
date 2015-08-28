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
  @IBOutlet weak var clueTextView: UITextView!
  @IBOutlet weak var viewForSearchBar: UIView!
  
  //MARK: Properties
  var delegate: CheckpointCreatorDelegate?
  let resultsTableController = UITableViewController()
  var searchController: UISearchController!
  var placePredictions: [(placeName: String, placeID: String)] = []
  var clueText: String?
  
  var checkpoint: Checkpoint? {
    didSet {
      updateUI()
    }
  }
  private func updateUI() {
    clueTextView?.text = checkpoint?.clue
    clueText = checkpoint?.clue
  }
  private var clueHasChanged = false

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneWasPressed")
    navigationItem.rightBarButtonItem = doneButton
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelWasPressed")
    navigationItem.leftBarButtonItem = cancelButton
    
    setCluePlaceholder()
    
    resultsTableController.tableView.frame = view.frame
    searchController = UISearchController(searchResultsController: resultsTableController)
    searchController.searchBar.sizeToFit()
    searchController.searchBar.placeholder = "Find a Place"
    viewForSearchBar.addSubview(searchController.searchBar)
    
    if let locationName = checkpoint?.locationName {
      searchController.searchBar.text = checkpoint?.locationName
      clueTextView.textColor = UIColor.blackColor()
      clueTextView.text = checkpoint?.clue
    }
    
    resultsTableController.tableView.delegate = self
    resultsTableController.tableView.dataSource = self
    resultsTableController.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    
    searchController.delegate = self
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    clueTextView.delegate = self
    
    definesPresentationContext = true
    
  }
  
  //MARK: Actions
  func saveCheckpoint() {
    if let checkpoint = checkpoint where clueHasChanged {
      clueHasChanged = false
      checkpoint.clue = clueTextView.text
      checkpoint.saveInBackgroundWithBlock { (success, error) -> Void in
        if let error = error {
          let alert = ErrorAlertHandler.errorAlertWithPrompt(error: "There was an error saving your checkpoint.  Please try again", handler: nil)
          self.presentViewController(alert, animated: true, completion: nil)
          
        } else if success {
          self.delegate?.checkpointCreatorDidSaveCheckpoint(checkpoint)
        }
      }
    }
  }
  
  func doneWasPressed() {
    saveCheckpoint()
    navigationController?.popViewControllerAnimated(true)
  }
  func cancelWasPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
  
  //MARK: Helper Methods
  func setCluePlaceholder() {
    clueTextView.textColor = UIColor.lightGrayColor()
    clueTextView.text = "Write a clue"
  }
  
  func clearCluePlaceholder() {
    clueTextView.textColor = UIColor.blackColor()
    clueTextView.text = clueText
  }
}

//MARK: Search Controller Table View Datasource
extension CheckpointCreatorViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placePredictions.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
    let placePrediction = placePredictions[indexPath.row]
    
    cell.textLabel?.text = placePrediction.placeName
    cell.detailTextLabel?.text = placePrediction.placeID
    
    return cell
  }
}

//MARK: Search Controller Table View Delegate
extension CheckpointCreatorViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let placePrediction = placePredictions[indexPath.row]
    
    checkpoint?.locationName = placePrediction.placeName
    checkpoint?.placeID = placePrediction.placeID
    
    GooglePlacesService.defaultService.detailsForPlaceID(placePrediction.placeID) { (details, error) in
      if let error = error {
        //TODO: Error Alert Handler Without Prompt
      } else if let details = details {
        let geoPoint = PFGeoPoint(location: details.location)
        self.checkpoint?.location = geoPoint
        self.checkpoint?.locationName = details.name
      }
      self.dismissViewControllerAnimated(true, completion: nil)
      self.searchController.searchBar.text = self.checkpoint?.locationName
    }
  }
}

//MARK: Search Bar Delegate
extension CheckpointCreatorViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    presentViewController(searchController, animated: true, completion: nil)
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {

  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    searchController.resignFirstResponder()
  }
}

//MARK: Search Controller Delegate
extension CheckpointCreatorViewController: UISearchControllerDelegate {
  
}

//MARK: Search Results Updating
extension CheckpointCreatorViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let query = searchController.searchBar.text
    GooglePlacesService.defaultService.resultsFromAutoCompleteQuery(query) { (placePredictions, error) in
      if let error = error {
        //TODO: Alert Controller for error
      } else if let placePredictions = placePredictions {
        self.placePredictions = placePredictions
        self.resultsTableController.tableView.reloadData()
      }
    }
  }
}

extension CheckpointCreatorViewController: UITextViewDelegate {
  func textViewDidBeginEditing(textView: UITextView) {
    clearCluePlaceholder()
    clueHasChanged = true
  }
  
  func textViewDidChange(textView: UITextView) {
    clueText = textView.text
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if clueText == nil || clueText == "" {
      setCluePlaceholder()
    }
  }
}





