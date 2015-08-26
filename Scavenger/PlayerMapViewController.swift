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
  var hunt: Hunt!
  var checkpoints: [Checkpoint]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = hunt.name
    
    ParseService.fetchCheckpointsForHunt(hunt, sortOrder: .Distance) { (checkpoints, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Could not retrieve checkpoints", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let checkpoints = checkpoints {
        self.checkpoints = checkpoints
        self.setAnnotationsForCheckpoints()
      }
    }
    
    //Testing
    var latitude: CLLocationDegrees = 47.623718
    var longitude: CLLocationDegrees = -122.336026
    var latDelta: CLLocationDegrees = 0.01
    var longDelta:CLLocationDegrees = 0.01
    var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
    var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
    var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
    mapView.setRegion(region, animated: true)
  }
  
  func setAnnotationsForCheckpoints() {
    if let checkpoints = checkpoints {
      var annotations = [MKPointAnnotation]()
      for checkpoint in checkpoints {
        var annotation = MKPointAnnotation()
        annotation.coordinate = checkpoint.coreLocation.coordinate
        annotation.title = checkpoint.locationName
        annotations.append(annotation)
      }
      mapView.showAnnotations(annotations, animated: true)
    }
  }
}



