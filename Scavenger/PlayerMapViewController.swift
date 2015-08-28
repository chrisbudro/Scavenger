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
  let kFailureLatitude = 47.623559
  let kFailureLongitude = -122.336069
  let kCheckInDistanceLimit = 0.05
  let kLocationAccuracy = 10.0          // meters
  let kLocationTimeInterval = 15.0      //seconds
  let kDemonstratinoMode = true

  
  //MARK: Properties
  var hunt: Hunt!
  var checkpoints: [Checkpoint]?
  var completedCheckpoints = [Checkpoint]()
  var mapView: GMSMapView!
  
  //MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = hunt.name
    
    // quick, in foreground, method of getting location is more accurate if we
    // have already collected some location samples
    let locationService = AppDelegate.Location.Service
    locationService.currentLocationWithBlock(accuracy: kLocationAccuracy, interval: kLocationTimeInterval) { (location, error) -> Void in
      if let location = location {
        println("locationB: \(location.description)")
      }  else if let error = error {
        println("error: \(error.localizedDescription)")
      }
    }

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
        if let coreLocation = checkpoint.coreLocation {
          let northPoint = GMSGeometryOffset(coreLocation.coordinate, kRegionCircleRadius, 0)
          let southPoint = GMSGeometryOffset(coreLocation.coordinate, kRegionCircleRadius, 180)
          let eastPoint = GMSGeometryOffset(coreLocation.coordinate, kRegionCircleRadius, 90)
          let westPoint = GMSGeometryOffset(coreLocation.coordinate, kRegionCircleRadius, 270)
          path.addCoordinate(northPoint)
          path.addCoordinate(southPoint)
          path.addCoordinate(eastPoint)
          path.addCoordinate(westPoint)
        }
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
          if let position = setCheckpoint(checkpoint) {
            // TODO
          }
        }
      }
    }
  }
  
  func setCheckpoint(checkpoint: Checkpoint) -> CLLocationCoordinate2D? {
    if checkpoint.coreLocation == nil {
      return nil
    }
    let actualPosition = checkpoint.coreLocation!.coordinate
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
  
  // for testing and demonstration
  func randomLocation(checkpoints: [Checkpoint]) -> Checkpoint? {
    if checkpoints.isEmpty { return nil }
    return checkpoints[Int(arc4random_uniform(UInt32(checkpoints.count)))]
  }
  
  func completeCheckpoint() {
    var currentLocation: PFGeoPoint?
    if let location = LocationService.currentLocation() {
      currentLocation = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      println("locationF: \(location.description)")
    } else {
      currentLocation = PFGeoPoint(latitude: kFailureLatitude,longitude: -kFailureLongitude)
    }
    
    // if demonstrating or testing then check if at least one location is close enough
    // otherwise reset currentLocation to a random location
    if kDemonstratinoMode, let checkpoints = checkpoints, testLocation = currentLocation {
      var closeCheckpoint = false
      var farCheckpoints = [Checkpoint]()
      for checkpoint in checkpoints {
        if testLocation.distanceInKilometersTo(checkpoint.location) < kCheckInDistanceLimit  {
          closeCheckpoint = true
          break
        } else if !checkpoint.completed {
          farCheckpoints.append(checkpoint)
        }
      }
      if !closeCheckpoint, let randomLocation = randomLocation(farCheckpoints) {
        currentLocation = randomLocation.location
      }
    }
    
    if let
      checkpoints = checkpoints,
      sortedCheckpoints = ParseService.checkpointsByDistance(checkpoints, currentLocation: currentLocation!)
      where sortedCheckpoints.count > 0 {
        let closestCheckpoint = sortedCheckpoints.first!
      if currentLocation!.distanceInKilometersTo(closestCheckpoint.location) < kCheckInDistanceLimit  {
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



