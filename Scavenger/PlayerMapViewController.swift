//
//  PlayerMapViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/25/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import MapKit

class PlayerMapViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.delegate = self
//      we need to decide what type we want this to be...not satellite
      mapView.mapType = .Satellite
    }
  }
//  This is when I would call the ParseService 
  
    override func viewDidLoad() {
        super.viewDidLoad()
      navigationItem.title = "Participant Map"
      
      var latitude: CLLocationDegrees = 47.623718
      var longitude: CLLocationDegrees = -122.336026
      var latDelta: CLLocationDegrees = 0.01
      var longDelta:CLLocationDegrees = 0.01
      var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
      var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
      var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
      mapView.setRegion(region, animated: true)
    
   
    }
//  
//  override func viewDidAppear(animated: Bool) {
//    <#code#>
//  }
//  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}



