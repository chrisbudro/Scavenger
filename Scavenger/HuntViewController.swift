//
//  HuntViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HuntViewController: UICollectionViewDataSource {
  

  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HuntCell", forIndexPath: indexPath) as! HuntCell
    
    cell.imageView.image = UIImage(named: "redx.png")
    cell.huntLabel.text = "First Hunt"
  
    return cell
  }
  
}