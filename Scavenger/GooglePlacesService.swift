//
//  GooglePlacesService.swift
//  Scavenger
//
//  Created by Chris Budro on 8/26/15.
//  Copyright (c) 2015 Chris Budro. All rights reserved.
//

import Foundation
import GoogleMaps
import Parse

class GooglePlacesService {
  static let defaultService = GooglePlacesService()
  private init() {}
  
  private let placesClient = GMSPlacesClient()
  
  func resultsFromAutoCompleteQuery(query: String, completion: ([(placeName: String, placeID: String)]?, error: String?) -> Void) {
    placesClient.autocompleteQuery(query, bounds: nil, filter: nil) { (predictions, error) -> Void in
      if let error = error {
        completion(nil, error: error.description)
      } else if let predictions = predictions as? [GMSAutocompletePrediction] {
        let placePredictions: [(placeName: String, placeID: String)] = predictions.map() { return ($0.attributedFullText.string, $0.placeID) }
        completion(placePredictions, error: nil)
      }
    }
  }
  
  func locationForPlaceID(placeID: String, completion: (location: CLLocation?, error: String?) -> Void) {
    placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
      if let error = error {
        completion(location: nil, error: error.description)
      } else if let place = place {
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        completion(location: location, error: nil)
      } else {
        completion(location: nil, error: "No place was found")
      }
    })
  }
  
  
}