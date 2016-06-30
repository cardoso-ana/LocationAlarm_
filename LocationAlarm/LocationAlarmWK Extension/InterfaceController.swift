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
        
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
        } else {
            
            presentAlertControllerWithTitle("Error", message: "oh no", preferredStyle: .Alert, actions: [])
            
        }

        
    }
    
    //TODO: Label distancia nao atualiza se location estiver parada.
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        
        if message["isAlarmActivated"] != nil{
        alarmIsActivated = ((message["isAlarmActivated"] as? Bool))!
        }
        
        if message["arrived"] != nil{
          
          let messageText = message["arrived"] as! String
          
          presentAlertControllerWithTitle(nil, message: messageText, preferredStyle: WKAlertControllerStyle.Alert, actions: [WKAlertAction(title: "OK", style: .Cancel, handler: { _ in
                
                print("foda-se")
                
            })])
                
            return
            
        }
        
        // ARRIVD

        
        if self.alarmIsActivated == true {
            
            var distanciaText = " "
            
            print("message distancia é \(message["distancia"])")
            if message["distancia"] != nil{
            distanciaText = message["distancia"] as! String
            print(" ___ distanciaText é \(distanciaText)")
                
            }
            
            distanceLabel.setText(distanciaText)

            captionLabel.setText("distance to alarm")
            actionButton.setHidden(false)
            
            print(" ___ distanciaText é lele \(distanciaText)")

            
        } else {
            
            distanceLabel.setText(" ")
            captionLabel.setText("Alarm deactivated")
            actionButton.setHidden(true)
            
        }
        
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        

        
        if applicationContext["isAlarmActivated"] != nil{
            alarmIsActivated = ((applicationContext["isAlarmActivated"] as? Bool))!
        }
        
        if applicationContext["arrived"] != nil{
          
          let messageText = applicationContext["arrived"] as! String
            
            presentAlertControllerWithTitle(nil, message: messageText, preferredStyle: WKAlertControllerStyle.Alert, actions: [WKAlertAction(title: "OK", style: .Cancel, handler: { _ in
                
                print("foda-se")
                
            })])
            
            return
            
        }
        
        
        if self.alarmIsActivated == true {
            
            var distanciaText = " "
            
            print("application context distancia é \(applicationContext["distancia"])")
            if applicationContext["distancia"] != nil{
                distanciaText = applicationContext["distancia"] as! String
                print(" ___ distanciaText é \(distanciaText)")
                
            }
            
            distanceLabel.setText(distanciaText)
            
            captionLabel.setText("distance to alarm")
            actionButton.setHidden(false)
            
            print(" ___ distanciaText é lele \(distanciaText)")
            
            
        } else {
            
            distanceLabel.setText(" ")
            captionLabel.setText("Alarm deactivated")
            actionButton.setHidden(true)
            
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
