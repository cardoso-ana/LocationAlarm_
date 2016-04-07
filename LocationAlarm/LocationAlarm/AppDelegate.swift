//
//  AppDelegate.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate
{

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
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
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active
        {
            let message = region.identifier
            
            if let viewController = window?.rootViewController
            {
                ((window?.rootViewController?.childViewControllers.first) as! MapViewController).playMedia()
                showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
            }
            
        }
            
        else
        {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = region.identifier
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            ((window?.rootViewController?.childViewControllers.first) as! MapViewController).playMedia()
        }
        
        locationManager.stopMonitoringForRegion(region)
        let viewController = window?.rootViewController?.childViewControllers.first as! MapViewController
        viewController.alarmeAtivado = false
        viewController.labelDistancia.text = ""
        viewController.self.navigationController?.setNavigationBarHidden(false, animated: true)
        viewController.imageDim.image = nil
        viewController.sliderRaio.hidden = false
        viewController.sliderRaio.userInteractionEnabled = true
        viewController.viewSlider!.hidden = false
        viewController.musicLabel.userInteractionEnabled = true
        viewController.activeButton.setTitle("ATIVAR", forState: UIControlState.Normal)
        viewController.activeButton.backgroundColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        print("entrou")
        if region is CLCircularRegion
        {
            handleRegionEvent(region)
        }
    }

    func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: alertOkHandler)
        alert.addAction(action)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func alertOkHandler(alert: UIAlertAction!)
    {
        (window?.rootViewController!.childViewControllers.first as! MapViewController).musicPlayer.stop()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void)
    {
        (window?.rootViewController!.childViewControllers.first as! MapViewController).musicPlayer.stop()
        completionHandler()
    }

}

