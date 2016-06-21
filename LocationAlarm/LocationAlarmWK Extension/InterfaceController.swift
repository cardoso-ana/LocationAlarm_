//
//  InterfaceController.swift
//  LocationAlarmWK Extension
//
//  Created by Gabriella Lopes on 6/21/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    @IBOutlet var distanceLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if WCSession.isSupported() {
            
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
        } else {
            
            presentAlertControllerWithTitle("Error", message: "oh no", preferredStyle: .Alert, actions: [])
            
        }
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        let distanciaText = message["distancia"] as! String
        distanceLabel.setText(distanciaText)
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
