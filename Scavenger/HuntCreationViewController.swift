//
//  HuntCreationViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/24/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit

class HuntCreationViewController: UIViewController {
  
  @IBOutlet weak var creatorName: UITextField!
  @IBOutlet weak var huntName: UITextField!
  @IBOutlet weak var huntDetail: UITextField!
  
  @IBAction func creatorNameDidEnd(sender: AnyObject) {
  }
  
  @IBAction func huntNameDidEnd(sender: AnyObject) {
  }
  
  @IBAction func huntDetailDidEnd(sender: AnyObject) {
  }
  
  @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

       navigationItem.title = "Hunt Creator"
       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed")
      
    }

  
}
