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
    
    func startMonitoringGeotification(geotification: Alarm)
    {
        print("monitoring")
        // 1
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
        {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: (window?.rootViewController)!)
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways
        {
            showSimpleAlertWithTitle("Warning", message: "Your alarm is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: (window?.rootViewController)!)
        }
        // 3
        geotification.alarmeRegion?.notifyOnEntry = true
        geotification.alarmeRegion?.notifyOnExit = false
        locationManager.startMonitoringForRegion(geotification.alarmeRegion!)
        print(locationManager.monitoredRegions)
    }
    
    func stopMonitoringGeotification(geotification: Alarm)
    {
        for region in locationManager.monitoredRegions
        {
            if let circularRegion = region as? CLCircularRegion
            {
                if circularRegion.identifier == geotification.identifier
                {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    func handleRegionEvent(region: CLRegion)
    {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active
        {
            let message = region.identifier
            
            if let viewController = window?.rootViewController
            {
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
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        print("entrou")
        if region is CLCircularRegion
        {
            handleRegionEvent(region)
        }
    }


}

