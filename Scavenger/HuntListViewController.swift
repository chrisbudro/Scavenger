//
//  HuntListViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntListViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var hunts = [Hunt]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ParseService.loadHunts { (hunts, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: error, handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let hunts = hunts {
        self.hunts = hunts
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

extension HuntListViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hunts.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HuntCell", forIndexPath: indexPath) as! HuntCell
    
    cell.imageView.image = UIImage(named: "redx.png")
    cell.hunt = hunts[indexPath.row]
  
    return cell
  }
}

extension HuntListViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let hunt = hunts[indexPath.row]
    performSegueWithIdentifier("showHuntDetail", sender: self)
  }
}