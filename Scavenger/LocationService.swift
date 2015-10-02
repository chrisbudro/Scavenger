//
//  LocationService.swift
//  Scavenger
//
//  Created by mike davis on 8/25/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import CoreLocation

class LocationService: NSObject {
  private let initialDistanceFilter = 10.0    // meters
  private let inRegionDistanceFilter = 5.0    // meters
  private lazy var manager = CLLocationManager()
  
  private var currentLocationUpdatingStarted: NSDate?
  private var currentLocationCompletionHander: ((location: CLLocation?, error: NSError?) -> Void)?
  private var currentLocationAccuracy = kCLLocationAccuracyBest
  private var currentLocationUpdatingDuration: NSTimeInterval = 0
  private let currentLocationElapsedMaxSeconds = 15.0
  private let currentLocationAccuracyMinMeters = 10.0
  
  override init() {
    super.init()
    isAuthorized()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.distanceFilter = initialDistanceFilter
    manager.activityType = CLActivityType.Fitness
    manager.delegate = self
  }
  
  func isAuthorized() -> NSError? {
    var authorized = false
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case CLAuthorizationStatus.AuthorizedAlways:
      //print("authorized always")
      authorized = true
    case CLAuthorizationStatus.AuthorizedWhenInUse:
      //print("authorized when in use")
      authorized = true
      break
    case CLAuthorizationStatus.Denied:
      //print("authorization denied")
      break
    case CLAuthorizationStatus.NotDetermined:
      //print("authorization not determined")
      //manager.requestAlwaysAuthorization()
      manager.requestWhenInUseAuthorization()
    case CLAuthorizationStatus.Restricted: print("authorization restricted")
    }
    let enabled = CLLocationManager.locationServicesEnabled()
    //print(enabled)
    let available = true
    //let available = CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
    //let available = CLLocationManager.significantLocationChangeMonitoringAvailable()
    //print(available)
    if authorized && enabled && available {
      return nil
    }
    return NSError(domain: "\(authorized),\(enabled),\(available);", code: Int(status.rawValue), userInfo: nil)
  }
  
  private func cleanupRegionMonitoring() {
    // this stops ALL regions
    for region in manager.monitoredRegions {
      manager.stopMonitoringForRegion(region)
    }
  }
  private func cleanupCurrentLocationMonitoring() {
    currentLocationUpdatingStarted = nil
    currentLocationCompletionHander = nil
    //print("stopUpdatingLocation")
    manager.stopUpdatingLocation()
  }
  private func cleanupSignificantLocationMonitoring() {
    manager.stopMonitoringSignificantLocationChanges()
  }
  deinit {
    //cleanupRegionMonitoring()
    cleanupCurrentLocationMonitoring()
    //cleanupSignificantLocationMonitoring()
  }

  func currentLocationWithBlock(accuracy accuracy: Double, interval: NSTimeInterval, completion: (location: CLLocation?, error: NSError?) -> Void) {

    if let error = isAuthorized() {
      completion(location: nil, error: error)
      return
    }
    currentLocationCompletionHander = completion
    currentLocationUpdatingStarted = NSDate()
    //println("startUpdatingLocation")
    manager.startUpdatingLocation()
  }
  
  class func currentLocation() -> CLLocation? {
    
    let pulseLocationSvc = LocationService()
    if let _ = pulseLocationSvc.isAuthorized() {
      return nil
    }
    pulseLocationSvc.manager.desiredAccuracy = kCLLocationAccuracyBest
    pulseLocationSvc.manager.startUpdatingLocation()
    pulseLocationSvc.manager.stopUpdatingLocation()
    if let location = pulseLocationSvc.manager.location {
      return location
    }
    return nil
  }
}

extension LocationService: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if locations.isEmpty { return }
    let location = locations.last!
    let accuracy = location.horizontalAccuracy
    if let elapsed = currentLocationUpdatingStarted?.timeIntervalSinceNow where -elapsed > currentLocationElapsedMaxSeconds {
      if let currentLocationCompletionHander = currentLocationCompletionHander {
        let error = NSError(domain: "Time Interval for currentLocationWithBlock exceeded.", code: Int(elapsed), userInfo: nil)
        currentLocationCompletionHander(location: location, error: error)
      }
      cleanupCurrentLocationMonitoring()
      return
    }
    if accuracy < 0 || accuracy > currentLocationAccuracyMinMeters {
      return
    }
    if let currentLocationCompletionHander = currentLocationCompletionHander {
      currentLocationCompletionHander(location: location, error: nil)
    }
    cleanupCurrentLocationMonitoring()
  }
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: \(error.localizedDescription)")
    cleanupCurrentLocationMonitoring()
  }
  func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
    print("didPauseLocatonUpdates:")
  }
  func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
    print("didResumeLocationUpdates:")
  }
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("didEnterRegion: \(region.identifier)")
    print(manager.location?.description)
  }
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("didExitRegion: \(region.identifier)")
    print(manager.location?.description)
  }
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
    switch state {
    case .Unknown:
      print("didDetermineState: Unknown")
    case .Inside:
      print("didDetermineState: INSIDE!")
    case .Outside:
      print("didDetermineState: OUTSIDE!")
    }
  }
  func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
    print("monitoringDidFailForRegion: \(region?.identifier)")
  }
}