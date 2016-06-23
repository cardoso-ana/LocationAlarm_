//
//  ContentViewController.swift
//  LocationAlarm
//
//  Created by Gabriella Lopes on 6/7/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ContentViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var viewDoVideo: UIView!
    
    var pageIndex: Int!
    var titleText: String!
    var captionText: String!
    var videoName: String!
    
    let playerLayer = AVPlayerLayer()
    var player = AVPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.titleLabel.text = self.titleText
        self.captionLabel.text = self.captionText

        print(#function)
        
        
        let filePath = NSBundle.mainBundle().pathForResource(videoName, ofType: "mov")
        
        print("____VIDEO NAME: \(videoName)____")
        print("_____FILE PATH: \(filePath)_____")
        
        let fileUrl = NSURL(fileURLWithPath: filePath!)
        player = AVPlayer(URL: fileUrl)
        
        playerLayer.player = player
        viewDoVideo.layer.addSublayer(playerLayer)
        
        player.play()
        player.rate = 2.0
    }
    
    override func viewWillAppear(animated: Bool)
    {
        print(#function)
        
        player.seekToTime(kCMTimeZero)
        player.play()
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        print(#function)
    }
    
    
    override func viewDidLayoutSubviews()
    {
        playerLayer.frame = viewDoVideo.bounds
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}