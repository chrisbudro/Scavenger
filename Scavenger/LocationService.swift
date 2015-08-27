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
      //println("authorized always")
      authorized = true
    case CLAuthorizationStatus.AuthorizedWhenInUse:
      //println("authorized when in use")
      authorized = true
      break
    case CLAuthorizationStatus.Denied:
      //println("authorization denied")
      break
    case CLAuthorizationStatus.NotDetermined:
      println("authorization not determined")
      //manager.requestAlwaysAuthorization()
      manager.requestWhenInUseAuthorization()
    case CLAuthorizationStatus.Restricted: println("authorization restricted")
    }
    let enabled = CLLocationManager.locationServicesEnabled()
    //println(enabled)
    let available = true
    //let available = CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
    //let available = CLLocationManager.significantLocationChangeMonitoringAvailable()
    //println(available)
    if authorized && enabled && available {
      return nil
    }
    return NSError(domain: "\(authorized),\(enabled),\(available)", code: Int(status.rawValue), userInfo: nil)
  }
  
  private func cleanupRegionMonitoring() {
    // this stops ALL regions
    for region in manager.monitoredRegions {
      if let region = region as? CLRegion {
        manager.stopMonitoringForRegion(region)
      }
    }
  }
  private func cleanupCurrentLocationMonitoring() {
    currentLocationUpdatingStarted = nil
    currentLocationCompletionHander = nil
    println("stopUpdatingLocation")
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

  func currentLocationWithBlock(accuracy: Double, interval: NSTimeInterval, completion: (location: CLLocation?, error: NSError?) -> Void) {

    var error: NSError?
    if let error = isAuthorized() {
      completion(location: nil, error: error)
      return
    }
    currentLocationCompletionHander = completion
    currentLocationUpdatingStarted = NSDate()
    println("startUpdatingLocation")
    manager.startUpdatingLocation()
  }
  
  class func currentLocation() -> CLLocation? {
    
    let pulseCount = 1
    let pulseLocationSvc = LocationService()
    if let error = pulseLocationSvc.isAuthorized() {
      return nil
    }
    pulseLocationSvc.manager.desiredAccuracy = kCLLocationAccuracyBest
    for var i = 0; i < pulseCount; i++ {
      pulseLocationSvc.manager.startUpdatingLocation()
      pulseLocationSvc.manager.stopUpdatingLocation()
      if let location = pulseLocationSvc.manager.location {
        println("pulse location manager (\(i+1); accuracy:  \(location.horizontalAccuracy))")
      }
      if let location = pulseLocationSvc.manager.location where location.horizontalAccuracy <= 15.0 {
        return location
      }
    }
    return nil
  }
}

extension LocationService: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    if locations.isEmpty { return }
    let location = locations.last as! CLLocation
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
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("didFailWithError: \(error.localizedDescription)")
    cleanupCurrentLocationMonitoring()
  }
  func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
    println("didPauseLocatonUpdates:")
  }
  func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
    println("didResumeLocationUpdates:")
  }
  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    println("didEnterRegion: \(region.identifier)")
    println(manager.location.description)
  }
  func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    println("didExitRegion: \(region.identifier)")
    println(manager.location.description)
  }
  func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
    switch state {
    case .Unknown:
      println("didDetermineState: Unknown")
    case .Inside:
      println("didDetermineState: INSIDE!")
    case .Outside:
      println("didDetermineState: OUTSIDE!")
    }
  }
  func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
    println("monitoringDidFailForRegion: \(region.identifier)")
  }
}