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
    @IBOutlet var captionLabel: WKInterfaceLabel!
    var alarmIsActivated = false
    @IBOutlet var actionButton: WKInterfaceButton!
    var session: WCSession!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        if WCSession.isSupported() {
            
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
        } else {
            
            presentAlertControllerWithTitle("Error", message: "oh no", preferredStyle: .Alert, actions: [])
            
        }

        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        if message["tappedWKButton"] != nil{
            print("NAO TO ACREDITANDOOOO")
        }
        
        if message["isAlarmActivated"] != nil{
        alarmIsActivated = ((message["isAlarmActivated"] as? Bool))!
        }

        
        if self.alarmIsActivated == true {
            
            var distanciaText = " "
            
            if message["distancia"] != nil{
            distanciaText = message["distancia"] as! String
            }
            
            distanceLabel.setText(distanciaText)

            captionLabel.setText("distance to alarm")
            actionButton.setEnabled(true)
            
        } else {
            
            distanceLabel.setText(" ")
            captionLabel.setText("Alarm Deactivated")
            actionButton.setEnabled(false)
            
        }
        
    }
    
    
    @IBAction func tappedActionButton() {
        
       
            session.sendMessage(["tappedWCButton":"lala"], replyHandler: nil, errorHandler: nil)
            print("__OXE MENINA LANÇOU O BAGULHO")
            
            
        }
        
        
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
