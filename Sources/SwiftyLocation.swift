//
//  SwiftyLocation.swift
//  SwiftyLocation
//
//  Created by Chris Hu on 17/12/5.
//  Copyright © 2017年 com.icetime. All rights reserved.
//


import Foundation
import CoreLocation

// MARK: - CSLocation

struct CSLocation {
    var location: CLLocation!
    var placmark: CLPlacemark!
    
    var region: CLRegion? {
        return placmark.region
    }
    var timeZone: TimeZone? {
        return placmark.timeZone
    }
    var ocean: String? {
        return placmark.ocean
    }
    var country: String? {
        return placmark.country
    }
    var administrativeArea: String? {
        return placmark.administrativeArea
    }
    var subAdministrativeArea: String? {
        return placmark.subAdministrativeArea
    }
    var locality: String? {
        return placmark.locality
    }
    var subLocality: String? {
        return placmark.subLocality
    }
    var name: String? {
        return placmark.name
    }
    var thoroughfare: String? {
        return placmark.thoroughfare
    }
    var subThoroughfare: String? {
        return placmark.subThoroughfare
    }
    var postalCode: String? {
        return placmark.postalCode
    }
    var isoCountryCode: String? {
        return placmark.isoCountryCode
    }
    var inlandWater: String? {
        return placmark.inlandWater
    }
    var areasOfInterest: [String]? {
        return placmark.areasOfInterest
    }
    var areaOfInterest: String? {
        return placmark.areasOfInterest?.first
    }
    
    var province: String? { return administrativeArea }
    var city: String? { return locality }
    var district: String? { return subLocality }
    var street: String? { return thoroughfare }
    var number: String? { return subThoroughfare }
    var desc: String? {
        if areaOfInterest?.isEmpty != nil {
            return areaOfInterest
        } else if name?.isEmpty != nil {
            return name
        } else {
            return street
        }
    }
}

// MARK: - SwiftyLocationDelegate

protocol SwiftyLocationDelegate {
    func SwiftyLocationDidUpdateLocation(_ csLocation: CSLocation)
}

// MARK: - SwiftyLocation

let kNotificationSwiftyLocationDidUpdated = "kNotificationSwiftyLocationDidUpdated"

class SwiftyLocation: NSObject {
    
    var delegate: SwiftyLocationDelegate?
    var currentCsLocation: CSLocation?
    
    fileprivate var appLanguages: Any?
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var geoCoder: CLGeocoder!
    
    private static let sharedInstance = SwiftyLocation()
    class var shared: SwiftyLocation {
        if sharedInstance.locationManager == nil {
            sharedInstance.initLocationManager()
            sharedInstance.geoCoder = CLGeocoder()
        }
        return sharedInstance
    }
    
}

extension SwiftyLocation {
    fileprivate func initLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            // (Configuration of your location manager object must always occur on a thread with an active run loop,
            // such as your application’s main thread.)
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            locationManager.delegate = self
        } else {
            print("SwiftyLocation : Location service is unavailable currently.")
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            if locationManager != nil {
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    func startLocation() {
        if locationManager != nil {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocation() {
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    fileprivate func parseSwiftyLocation( _ location: CLLocation,
                                          completion: @escaping (_ csLocation: CSLocation) -> Void) {
        DispatchQueue.global().async {
            self.p_parseSwiftyLocation(location) { (placemarks, error) in
                UserDefaults.standard.set(self.appLanguages, forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                
                guard let placemark = placemarks?.first else { return }
                
                var csLocation = CSLocation()
                csLocation.location = location
                csLocation.placmark = placemark
                
                completion(csLocation)
            }
        }
    }
    
    private func p_parseSwiftyLocation(_ location: CLLocation,
                                       completionHandler: @escaping CoreLocation.CLGeocodeCompletionHandler) {
        appLanguages = UserDefaults.standard.object(forKey: "AppleLanguages")
        UserDefaults.standard.setValue(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: completionHandler)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension SwiftyLocation: CLLocationManagerDelegate {
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        parseSwiftyLocation(location) { (csLocation) in
            self.currentCsLocation = csLocation
            
            if self.delegate != nil {
                self.delegate?.SwiftyLocationDidUpdateLocation(csLocation)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationSwiftyLocationDidUpdated),
                                            object: nil)
        }
    }
}
