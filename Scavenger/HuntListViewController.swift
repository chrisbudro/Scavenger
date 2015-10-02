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
  let kHuntNameLabelHeight: CGFloat = 22
  let kNumberOfColumns: CGFloat = 3
  
  //MARK: Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  
  //MARK: Properties
  var hunts = [Hunt]()
  var refreshControl = UIRefreshControl()
  let placeholderImage = UIImage(named: "Icon-60-1.png")
  var numberOfDividers: CGFloat {
    return kNumberOfColumns - 1
  }
  
  //MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Sight Seeker"
    
    refreshControl.addTarget(self, action: "refreshHuntList", forControlEvents: UIControlEvents.ValueChanged)
    collectionView.addSubview(refreshControl)
    collectionView.alwaysBounceVertical = true
    setCellSize()

    let locationService = AppDelegate.Location.Service
    if let error = locationService.isAuthorized() {
      print("Core Location Services Not Ready. \(error.localizedDescription)")
    } else {
      print("Core Location Services Ready.")
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
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
      }
    }
  }
  
  func setCellSize() {
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let totalDividerSpace = numberOfDividers * layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let cellWidth = floor((screenWidth - totalDividerSpace) / kNumberOfColumns)
    let cellHeight = cellWidth + kHuntNameLabelHeight
    layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showHuntCreation", let vc = segue.destinationViewController as? CheckpointAdderViewController {
      vc.hunt = Hunt()
    } else if segue.identifier == "showHuntDetail", let vc = segue.destinationViewController as? HuntPlayerViewController, indexPath = collectionView.indexPathsForSelectedItems()?.first {
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
    if let huntImage = hunt.huntImage {
      cell.imageView.image = huntImage
    } else {
      cell.imageView.alpha = 0.0
      cell.huntLabel.alpha = 0
      cell.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5)
      
      ParseService.imageForHunt(hunt) { (image, error) in
        if let error = error {
          print(error)
          cell.imageView.image = self.placeholderImage
        } else if let image = image where tag == cell.tag {
          self.hunts[indexPath.row].huntImage = image
          cell.imageView.image = image
        }
      }

      if cell.imageView.alpha == 0 {
        UIView.animateWithDuration(0.3, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.6, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
          cell.imageView.transform = CGAffineTransformScale(cell.imageView.transform, 2.0, 2.0)
          cell.imageView.alpha = 1.0
          cell.huntLabel.alpha = 1.0
          }, completion: { (finished) -> Void in
            
        })
      }
    }
    return cell
  }
}

//MARK: Collection View Delegate

extension HuntListViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showHuntDetail", sender: self)
  }
}