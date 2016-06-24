//
//  AppDelegate.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import WatchConnectivity

var didEnterFromQA = false
var tipoCoisado = ""


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, WCSessionDelegate
{
    let model = Model.sharedInstance()
    var window: UIWindow?
    var alarmes:[Alarm] = []
    var distanceInMeters = "NO"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        if let yesOrNo = defaults.stringForKey("distanceInMeters")
        {
            distanceInMeters = yesOrNo
        }
        else
        {
            defaults.setObject("NO", forKey: "distanceInMeters")
            distanceInMeters = "NO"
        }
        
        
        LocationService.sharedInstance.locationManager!.requestAlwaysAuthorization()
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageController.currentPageIndicatorTintColor = UIColor.blackColor()
        pageController.backgroundColor = UIColor.whiteColor()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        print("vai entrar no if\n")
        //Check for ShortCutItem
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem
        {
            didEnterFromQA = true
            tipoCoisado = shortcutItem.type
            
            print("entrou no if\n\n\n")
            print(shortcutItem)
            
            return false
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func handleRegionEvent(region: CLRegion)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let soundName = defaults.stringForKey("currentSound")
        print(soundName)
        
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active
        {
            let message = region.identifier
            
            if let viewController = window?.rootViewController
            {
                let soundfile = NSBundle.mainBundle().URLForResource(soundName?.substringToIndex((soundName?.endIndex.advancedBy(-4))!), withExtension: "caf")
                showSimpleAlertWithTitle(nil, message: message, sound: soundfile!, viewController: viewController)
            }
            
        }
        else
        {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = region.identifier
            notification.soundName = soundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        LocationService.sharedInstance.locationManager!.stopMonitoringForRegion(region)
        let viewController = window?.rootViewController?.childViewControllers.first as! MapViewController
        viewController.alarmeAtivado = false
        viewController.changeDisplayDeactivated()
        
    }
    
    func showSimpleAlertWithTitle(title: String!, message: String, sound: NSURL, viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: alertOkHandler)
        alert.addAction(action)
        
        do {
            model.audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
            model.audioPlayer.play()
        }
        catch {
            debugPrint("\(error)")
        }
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertOkHandler(alert: UIAlertAction!)
    {
        model.audioPlayer.stop()
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void)
    {
        
        print("______Chegou a entrar no performActionForShortcutItem")
        
        if let LinkViewController = (window?.rootViewController!.childViewControllers.first as? MapViewController) {
            LinkViewController.activateByQuickAction(shortcutItem.type)
        }
        
        print("______Terminou o performActionForShortcutItem")
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        //TODO: fazer tela do watch mudar quando tá aberto e chega no lugar!!!
    }
    
    func formataDistânciaParaRegião(distancia: Double) -> String
    {
        var dist = distancia
        if distanceInMeters == "YES"
        {
            if dist < 1000
            {
                return "\(Int(dist)) m"
            }
            else
            {
                dist /= 1000
                return "\(dist.roundToPlaces(2)) km"
            }
        }
        else
        {
            dist = dist / 1609.344
            if dist < 0.1
            {
                dist = dist * 5280
                return "\(Int(dist)) ft"
            }
            else
            {
                return "\(dist.roundToPlaces(1)) mi"
            }
        }
    }
    
    
    func chamaWatch()
    {
        print("chamou o watch")
        if WCSession.isSupported() {
            print("session supported")
            
            let wcsession = WCSession.defaultSession()
            if wcsession.reachable{
                
                if let savedAlarms = defaults.objectForKey("alarmes") as? NSData
                {
                    alarmes = NSKeyedUnarchiver.unarchiveObjectWithData(savedAlarms) as! [Alarm]
                }
                
                
                let alarmeAtual = alarmes[0]
              
                let lugarDois = CLLocation(latitude: alarmeAtual.coordinate.latitude, longitude: alarmeAtual.coordinate.longitude)
                let distanciaParaCentro = LocationService.sharedInstance.locationManager!.location?.distanceFromLocation(lugarDois)
                let distanciaParaRegiao = distanciaParaCentro! - alarmeAtual.radius
                
                if let yesOrNo = defaults.stringForKey("distanceInMeters") {
                    distanceInMeters = yesOrNo
                }
                print("IS IT IN METERS IN PLIST \(defaults.stringForKey("distanceInMeters"))")
                
                let textoDistancia = formataDistânciaParaRegião(distanciaParaRegiao)
                print("texto distancia ____ \(textoDistancia)")
                
                wcsession.sendMessage(["distancia":textoDistancia], replyHandler: nil, errorHandler: nil)
            }
        }
    }
}

