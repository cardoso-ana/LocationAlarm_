//
//  ChooseSongViewController.swift
//  LocationAlarm
//
//  Created by Gabriella Lopes on 5/5/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import AVFoundation

class ChooseSongViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    let model = Model.sharedInstance()
    
    var soundFiles : [NSURL] = []
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    let soundNames = ["Boss calling", "Drone", "Error", "Goodnight", "Ring n roll", "Simple", "Squirrels", "Supertux", "There is no phone"]
    
    var lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        soundFiles = NSBundle.mainBundle().URLsForResourcesWithExtension("caf", subdirectory: nil)! as [NSURL]
        print(soundFiles)
        
        for (index, file) in soundFiles.enumerate()
        {
            if file.lastPathComponent == defaults.stringForKey("currentSound")
            {
                lastSelectedIndexPath = NSIndexPath(forRow: index, inSection: 0)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print(soundFiles.indices)
        return soundFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath:  indexPath) as! ChooseSongTableViewCell
        cell.accessoryType = .None
        
        //let directory: String = soundFiles[indexPath.section].directory
        //let fileName: String = String(soundFiles[indexPath.row].lastPathComponent)
        let filePath = soundFiles[indexPath.row]
        print(filePath)
        
        cell.songName.text = soundNames[indexPath.row]
        
        print(indexPath)
        print(lastSelectedIndexPath)
        
        if indexPath == lastSelectedIndexPath
        {
            cell.accessoryType = .Checkmark
            print("entrou no trequetaaaaaoooo ___")
            print(indexPath.row)
            print(lastSelectedIndexPath)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        tableView.cellForRowAtIndexPath(lastSelectedIndexPath)?.accessoryType = .None
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        
        print(lastSelectedIndexPath)
        
        lastSelectedIndexPath = indexPath
        
        
        print(lastSelectedIndexPath)
        
        
        //Play the sound
        let filePath = soundFiles[indexPath.row]
        do {
            model.audioPlayer = try AVAudioPlayer(contentsOfURL: filePath)
            model.audioPlayer.play()
        } catch {
            debugPrint("\(error)")
        }
    }
    
    
    
    override func viewWillDisappear(animated: Bool)
    {
        model.audioPlayer.stop()
        
        print(soundFiles[lastSelectedIndexPath.row].lastPathComponent)
        
        defaults.setValue(soundFiles[lastSelectedIndexPath.row].lastPathComponent, forKey: "currentSound")
        
        print(defaults.objectForKey("currentSound") as! String!)
        
    }
    
}
