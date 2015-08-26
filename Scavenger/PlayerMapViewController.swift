//
//  PlayerMapViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/25/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import GoogleMaps

class PlayerMapViewController: UIViewController {
  
  enum HuntStyle {
    case AllCheckpoints
    case CurrentCheckpoint
  }
  
  //MARK: Constants
  let kMapPadding: CGFloat = 128.0
  let kRegionCircleRadius: CLLocationDistance = 750
  let kRegionCirclePadding: CLLocationDistance = 200
  let kRegionCircleColor = UIColor(white: 0.8, alpha: 0.4)
  
  //MARK: Properties
  var hunt: Hunt!
  var checkpoints: [Checkpoint]?
  var mapView: GMSMapView!
  
  //MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = hunt.name
    showMysteryPreferenceAlert()
    
    
    mapView = GMSMapView(frame: view.frame)
    mapView.delegate = self
    view.addSubview(mapView)

    ParseService.fetchCheckpointsForHunt(hunt, sortOrder: .Distance) { (checkpoints, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Could not retrieve checkpoints", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let checkpoints = checkpoints {
        self.checkpoints = checkpoints
        self.setAnnotationsForCheckpoints(.AllCheckpoints)
      }
    }
  }
  
  //MARK: Helper Methods
  func showMysteryPreferenceAlert() {
    let alertController = UIAlertController(title: "Mystery Preference", message: "Would you like to see all of your clues at once, or find them as you go?", preferredStyle: .Alert)
    
    alertController.addAction(UIAlertAction(title: "Show All Checkpoints", style: .Default) { (action) in
      
    })
    presentViewController(alertController, animated: true, completion: nil)
  }

  func setAnnotationsForCheckpoints(huntStyle: HuntStyle) {
    
    var path = GMSMutablePath()
    if let checkpoints = checkpoints {
      for (index, checkpoint) in enumerate(checkpoints) {
        let actualPosition = checkpoint.coreLocation.coordinate
        if checkpoint.completed {
          let marker = GMSMarker(position: actualPosition)
          marker.map = mapView
          marker.title = checkpoint.locationName
          marker.snippet = checkpoint.clue
        } else {
          let offsetPosition = randomOffset(actualPosition)
          let circle = GMSCircle(position: offsetPosition, radius: kRegionCircleRadius)
          circle.fillColor = kRegionCircleColor
          circle.tappable = true
          circle.map = mapView
          circle.title = checkpoint.clue
          
          path.addCoordinate(offsetPosition)
        }
        let bounds = GMSCoordinateBounds(path: path)
        //      mapView.cameraForBounds(bounds, insets: UIEdgeInsets())
        let cameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding: kMapPadding)
        mapView.moveCamera(cameraUpdate)
      }
    }
  }
  
  func randomOffset(position: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let randomDistance: CLLocationDistance = Double(arc4random_uniform(600)) // Replace Magic Numbers
    let randomHeading: CLLocationDirection = Double(arc4random_uniform(360)) // Replace Magic Numbers
    let offsetPosition = GMSGeometryOffset(position, randomDistance, randomHeading)
    
    return offsetPosition
  }
}

extension PlayerMapViewController: GMSMapViewDelegate {
  func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
    if let circle = overlay as? GMSCircle {
     let marker = GMSMarker(position: circle.position)
      marker.layer.opacity = 0.0
      marker.title = circle.title
      marker.snippet = circle.title
      marker.map = mapView
      mapView.selectedMarker = marker
    }
  }
}



