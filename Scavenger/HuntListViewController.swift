//
//  HuntListViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntListViewController: UIViewController {
  
  //MARK: Constants
  let kImageAnimationDuration: CGFloat = 0.3
  
  //MARK: Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  
  //MARK: Properties
  var hunts = [Hunt]()
  var refreshControl = UIRefreshControl()
  let placeholderImage = UIImage(named: "redx.png")
  
  //MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl.addTarget(self, action: "refreshHuntList", forControlEvents: UIControlEvents.ValueChanged)
    collectionView.addSubview(refreshControl)
    collectionView.alwaysBounceVertical = true

    let locationService = AppDelegate.Location.Service
    if let error = locationService.isAuthorized() {
      println("Core Location Services Not Ready. \(error.localizedDescription)")
    } else {
      println("Core Location Services Ready.")
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadHunts()
  }
  
  //MARK: Helper Methods
  func refreshHuntList() {
    loadHunts()
  }
  
  func loadHunts() {
    ParseService.loadHunts { (hunts, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let hunts = hunts {
        self.hunts = hunts
        self.refreshControl.endRefreshing()
        self.collectionView.reloadData()
      }
    }
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showHuntCreation", let vc = segue.destinationViewController as? CheckpointAdderViewController {
      vc.hunt = Hunt()
    } else if segue.identifier == "showHuntDetail", let vc = segue.destinationViewController as? HuntPlayerViewController, indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath {
      vc.hunt = hunts[indexPath.row]
    }
  }
}

//MARK: Collection View Data Source
extension HuntListViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hunts.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HuntCell", forIndexPath: indexPath) as! HuntCell
    let hunt = hunts[indexPath.row]
    
    cell.imageView.image = nil
    cell.tag++
    let tag = cell.tag
    
    cell.hunt = hunt
    //    if let image = hunt.huntImage {
    //      cell.imageView.image = image
    //    } else {
    if hunt.huntImage == nil {
      cell.imageView.alpha = 0.0
      cell.huntLabel.alpha = 0
      cell.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5)
    }
    
    ParseService.imageForHunt(hunt) { (image, error) in
      if let error = error {
        println(error)
        self.hunts[indexPath.row].huntImage = self.placeholderImage
        hunt.huntImage = self.placeholderImage
        cell.imageView.image = self.placeholderImage
      } else if let image = image where tag == cell.tag {
        self.hunts[indexPath.row].huntImage = self.placeholderImage
        hunt.huntImage = image
        cell.imageView.image = image
      }
      
      if cell.imageView.alpha == 0 {
        UIView.animateWithDuration(0.3, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.6, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          cell.imageView.transform = CGAffineTransformScale(cell.imageView.transform, 2.0, 2.0)
          cell.imageView.alpha = 1.0
          cell.huntLabel.alpha = 1.0
          }, completion: { (finished) -> Void in
            
        })
      }
      //      }
    }
    return cell
  }
}

//MARK: Collection View Delegate

extension HuntListViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let hunt = hunts[indexPath.row]
    performSegueWithIdentifier("showHuntDetail", sender: self)
  }
}