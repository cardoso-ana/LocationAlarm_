//
//  Alert.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/30/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import Foundation
import MapKit


func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController)
{
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}