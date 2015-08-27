//
//  PlayerMapViewController.swift
//  Scavenger
//
//  Created by Sarah Hermanns on 8/25/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class PlayerMapViewController: UIViewController {
  

  
  //MARK: Constants
  let kMapPadding: CGFloat = 64
  let kRegionCircleRadius: CLLocationDistance = 750
  let kRegionCirclePadding: CLLocationDistance = 200
  let kRegionCircleColor = UIColor(white: 0.8, alpha: 0.4)
  
  //MARK: Properties
  var hunt: Hunt!
  var checkpoints: [Checkpoint]?
  var completedCheckpoints = [Checkpoint]()
  var mapView: GMSMapView!
  
  //MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = hunt.name
    
    if hunt.huntStyle == nil {
//      showMysteryPreferenceAlert()
    }
    
    let completeCheckpointButton = UIBarButtonItem(title: "Check In", style: .Done, target: self, action: "completeCheckpoint")
    navigationItem.rightBarButtonItem = completeCheckpointButton
    
    mapView = GMSMapView(frame: view.frame)
    mapView.delegate = self
    view.addSubview(mapView)

    ParseService.fetchCheckpointsForHunt(hunt, sortOrder: .Distance) { (checkpoints, error) -> Void in
      if let error = error {
        let alertController = ErrorAlertHandler.errorAlertWithPrompt(error: "Could not retrieve checkpoints", handler: nil)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if let checkpoints = checkpoints {
        self.checkpoints = checkpoints
        self.setAnnotationsForCheckpoints()
      }
    }
  }
  
  func setMapBounds() {
    var path = GMSMutablePath()
    if let checkpoints = checkpoints {
      for checkpoint in checkpoints {
        let northPoint = GMSGeometryOffset(checkpoint.coreLocation.coordinate, kRegionCircleRadius, 0)
        let southPoint = GMSGeometryOffset(checkpoint.coreLocation.coordinate, kRegionCircleRadius, 180)
        let eastPoint = GMSGeometryOffset(checkpoint.coreLocation.coordinate, kRegionCircleRadius, 90)
        let westPoint = GMSGeometryOffset(checkpoint.coreLocation.coordinate, kRegionCircleRadius, 270)
        path.addCoordinate(northPoint)
        path.addCoordinate(southPoint)
        path.addCoordinate(eastPoint)
        path.addCoordinate(westPoint)
      }
      let bounds = GMSCoordinateBounds(path: path)
      let cameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding: kMapPadding)
      mapView.moveCamera(cameraUpdate)
    }
  }
  
  //MARK: Helper Methods
  func showMysteryPreferenceAlert() {
    let alertController = UIAlertController(title: "Mystery Preference", message: "Would you like to see all of your clues at once, or find them as you go?", preferredStyle: .Alert)
    
    alertController.addAction(UIAlertAction(title: "Show all checkpoints", style: .Default) { (action) in
      self.hunt.huntStyle = .AllCheckpoints
    })
    
    alertController.addAction(UIAlertAction(title: "Show current checkpoint", style: .Default) { (action) in
      self.hunt.huntStyle = .CurrentCheckpoint
    })
    
    presentViewController(alertController, animated: true, completion: nil)
  }

  func setAnnotationsForCheckpoints() {
    setMapBounds()
    if let checkpoints = checkpoints {
      for checkpoints in [checkpoints, completedCheckpoints] {
        for (index, checkpoint) in enumerate(checkpoints) {
          let position = setCheckpoint(checkpoint)
          
        }
      }
    }
  }
  
  func setCheckpoint(checkpoint: Checkpoint) -> CLLocationCoordinate2D {
    let actualPosition = checkpoint.coreLocation.coordinate
    if checkpoint.completed {
      let marker = GMSMarker(position: actualPosition)
      marker.map = mapView
      marker.title = checkpoint.locationName
      marker.snippet = checkpoint.clue
      checkpoint.marker = marker
      
      return actualPosition
    } else {
      let offsetPosition = randomOffset(actualPosition)
      let circle = GMSCircle(position: offsetPosition, radius: kRegionCircleRadius)
      circle.fillColor = kRegionCircleColor
      circle.tappable = true
      circle.map = mapView
      circle.title = checkpoint.clue
      checkpoint.circleOverlay = circle
      
      return offsetPosition
    }
  }
  
  func randomOffset(position: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let randomDistance: CLLocationDistance = Double(arc4random_uniform(600)) // Replace Magic Numbers
    let randomHeading: CLLocationDirection = Double(arc4random_uniform(360)) // Replace Magic Numbers
    let offsetPosition = GMSGeometryOffset(position, randomDistance, randomHeading)
    
    return offsetPosition
  }
  
  func completeCheckpoint() {
    //TODO: remove Placeholder location
    let currentLocation = PFGeoPoint(latitude: 47.623559,longitude: -122.336069)
    if let
      checkpoints = checkpoints,
      sortedCheckpoints = ParseService.checkpointsByDistance(checkpoints, currentLocation: currentLocation)
      where sortedCheckpoints.count > 0 {
        let closestCheckpoint = sortedCheckpoints.first!
      if currentLocation.distanceInKilometersTo(closestCheckpoint.location) < 0.05  {
        closestCheckpoint.completed = true
        completedCheckpoints.append(closestCheckpoint)
        self.checkpoints!.removeAtIndex(0)
        closestCheckpoint.circleOverlay?.map = nil
        
        closestCheckpoint.setMarker()
        closestCheckpoint.marker?.map = mapView
        mapView.selectedMarker = closestCheckpoint.marker
      }
    }
  }
}

extension PlayerMapViewController: GMSMapViewDelegate {
  func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
    if let circle = overlay as? GMSCircle {
     let marker = GMSMarker(position: circle.position)
      marker.layer.opacity = 0.0
      marker.snippet = circle.title
      marker.map = mapView
      mapView.selectedMarker = marker
    }
  }
}



