//
//  Model.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 5/5/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import AVFoundation

class Model: NSObject
{
    ///Audio player responsible for playing sound files.
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    ///User's bookmarked sound files.
    var bookmarkedFiles: [String] = []
    
    ///User defaults
    var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    class func sharedInstance() -> Model
    {
        return modelSingletonGlobal
    }
}

///Model singleton so that we can refer to this from throughout the app.
let modelSingletonGlobal = Model()