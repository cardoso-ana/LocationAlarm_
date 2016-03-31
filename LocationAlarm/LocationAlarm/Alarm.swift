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
    
    var title: String? {
        if note.isEmpty {
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
        alarmeRegion = CLCircularRegion(center: self.coordinate, radius: self.radius, identifier: self.identifier)
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDoubleForKey(kGeotificationLatitudeKey)
        let longitude = decoder.decodeDoubleForKey(kGeotificationLongitudeKey)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDoubleForKey(kGeotificationRadiusKey)
        identifier = decoder.decodeObjectForKey(kGeotificationIdentifierKey) as! String
        note = decoder.decodeObjectForKey(kGeotificationNoteKey) as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(coordinate.latitude, forKey: kGeotificationLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kGeotificationLongitudeKey)
        coder.encodeDouble(radius, forKey: kGeotificationRadiusKey)
        coder.encodeObject(identifier, forKey: kGeotificationIdentifierKey)
        coder.encodeObject(note, forKey: kGeotificationNoteKey)
    }
}

