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

public struct CSLocation {
    public var location: CLLocation!
    public var placmark: CLPlacemark!
    
    public var region: CLRegion? {
        return placmark.region
    }
    public var timeZone: TimeZone? {
        return placmark.timeZone
    }
    public var ocean: String? {
        return placmark.ocean
    }
    public var country: String? {
        return placmark.country
    }
    public var administrativeArea: String? {
        return placmark.administrativeArea
    }
    public var subAdministrativeArea: String? {
        return placmark.subAdministrativeArea
    }
    public var locality: String? {
        return placmark.locality
    }
    public var subLocality: String? {
        return placmark.subLocality
    }
    public var name: String? {
        return placmark.name
    }
    public var thoroughfare: String? {
        return placmark.thoroughfare
    }
    public var subThoroughfare: String? {
        return placmark.subThoroughfare
    }
    public var postalCode: String? {
        return placmark.postalCode
    }
    public var isoCountryCode: String? {
        return placmark.isoCountryCode
    }
    public var inlandWater: String? {
        return placmark.inlandWater
    }
    public var areasOfInterest: [String]? {
        return placmark.areasOfInterest
    }
    public var areaOfInterest: String? {
        return placmark.areasOfInterest?.first
    }
    
    public var province: String? { return administrativeArea }
    public var city: String? { return locality }
    public var district: String? { return subLocality }
    public var street: String? { return thoroughfare }
    public var number: String? { return subThoroughfare }
    public var desc: String? {
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

public protocol SwiftyLocationDelegate {
    func SwiftyLocationDidUpdateLocation(_ csLocation: CSLocation)
}

// MARK: - SwiftyLocation

public let kNotificationSwiftyLocationDidUpdated = "kNotificationSwiftyLocationDidUpdated"

public class SwiftyLocation: NSObject {
    
    public var delegate: SwiftyLocationDelegate?
    public var currentCsLocation: CSLocation?
    
    fileprivate var appLanguages: Any?
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var geoCoder: CLGeocoder!
    
    static let shared = SwiftyLocation()
    override private init() {
        super.init()
        
        if self.locationManager == nil {
            self.initLocationManager()
            self.geoCoder = CLGeocoder()
        }
    }
    
}

public extension SwiftyLocation {
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
    
    public func startLocation() {
        if locationManager != nil {
            locationManager.startUpdatingLocation()
        }
    }
    
    public func stopLocation() {
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
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
