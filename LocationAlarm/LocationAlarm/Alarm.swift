//
//  Alarm.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/30/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

let kGeotificationLatitudeKey = "latitude"
let kGeotificationLongitudeKey = "longitude"
let kGeotificationRadiusKey = "radius"
let kGeotificationIdentifierKey = "identifier"
let kGeotificationNoteKey = "note"


class Alarm: NSObject, NSCoding, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var alarmeRegion: CLCircularRegion?
    var endereco: String?
    
    var title: String?
    {
        if note.isEmpty
        {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String?
    {
        return "Radius: \(radius)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String)
    {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.endereco = "Alarme recente"
        alarmeRegion = CLCircularRegion(center: self.coordinate, radius: self.radius, identifier: self.note)
        
        super.init()
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        getEndereco(location)
    }
    
    func getEndereco (location: CLLocation)
    {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            { (placemarks, error) -> Void in
                
                if placemarks!.count > 0
                {
                    let pm = placemarks![0]
                    
                    if let rua = pm.thoroughfare
                    {
                        self.endereco = ("\(rua)")
                        if let numero = pm.subThoroughfare
                        {
                            self.endereco = ("\(rua), \(numero)")
                        }
                        print("endereco = \(self.endereco)")
                    }
                }
                    
                else
                {
                    print("Problem with the data received from geocoder")
                }
                
                
                let allQAIcons = UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.Time)
                let QAItem = UIApplicationShortcutItem(type: self.identifier, localizedTitle: self.endereco!, localizedSubtitle: "\(String(Int(self.radius)))m", icon: allQAIcons, userInfo: nil)
                
                UIApplication.sharedApplication().shortcutItems?.insert(QAItem, atIndex: 0)
                print("::::Primeiro item do quick action: \(UIApplication.sharedApplication().shortcutItems?.first)")
                
                if UIApplication.sharedApplication().shortcutItems?.count >= 4
                {
                    UIApplication.sharedApplication().shortcutItems?.removeAtIndex(4)
                }
        })
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder)
    {
        let latitude = decoder.decodeDoubleForKey(kGeotificationLatitudeKey)
        let longitude = decoder.decodeDoubleForKey(kGeotificationLongitudeKey)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDoubleForKey(kGeotificationRadiusKey)
        identifier = decoder.decodeObjectForKey(kGeotificationIdentifierKey) as! String
        note = decoder.decodeObjectForKey(kGeotificationNoteKey) as! String
        
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeDouble(coordinate.latitude, forKey: kGeotificationLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kGeotificationLongitudeKey)
        coder.encodeDouble(radius, forKey: kGeotificationRadiusKey)
        coder.encodeObject(identifier, forKey: kGeotificationIdentifierKey)
        coder.encodeObject(note, forKey: kGeotificationNoteKey)
    }   
}

