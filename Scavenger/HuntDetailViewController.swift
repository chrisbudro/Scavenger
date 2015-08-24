//
//  HuntDetailViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntDetailViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBAction func segmentedControl(sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      tableView.reloadData()
      
    } else {
//      this is where we want to load the general bounds map view
    }
  }
  

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Hunt Detail"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HuntDetailViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("HuntDetailCell", forIndexPath: indexPath) as! HuntDetailCell
  
    return cell
  }
}