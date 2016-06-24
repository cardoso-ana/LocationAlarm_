//
//  Manager.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 6/23/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol LocationServiceDelegate
{
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate
{
    
    class var sharedInstance: LocationService
    {
        struct Static
        {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: LocationService? = nil
        }
        dispatch_once(&Static.onceToken)
        {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    
    override init()
    {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else
        {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined
        {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 50 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation()
    {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation()
    {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        // use for real time update location
        updateLocation(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        
        // do on error
        updateLocationDidFailWithError(error)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        print("entrou")
        if region is CLCircularRegion
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.handleRegionEvent(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }

    
    // Private function
    private func updateLocation(currentLocation: CLLocation)
    {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError)
    {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
}
