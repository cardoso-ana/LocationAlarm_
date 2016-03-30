//
//  Map.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class Map
{
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    func locationManagerInit()
    {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
    }
    
    func checkCoreLocationPermission()
    {
        let authorization = CLLocationManager.authorizationStatus()
        if authorization == .AuthorizedAlways
        {
            print("comecou o autorizado")
            locationManager.startUpdatingLocation()
        }
        else if authorization == .NotDetermined
        {
            locationManager.requestAlwaysAuthorization()
        }
        else
        {
            print(":::::: Access to user location not granted or unavailable.")
        }
    }
    
    //    //posiciona o mapa na localização do user
    //    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let location = locations.last
    //
    //        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    //        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    //
    //        self.mapView.setRegion(region, animated: true)
    //    }
    
    //posiciona o mapa no inicio
    
    func userLocation(manager: CLLocationManager, location: CLLocation) -> MKCoordinateRegion
    {
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        return region
    }
    
    
}