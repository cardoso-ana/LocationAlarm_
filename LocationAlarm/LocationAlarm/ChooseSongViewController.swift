//
//  ChooseSongViewController.swift
//  LocationAlarm
//
//  Created by Gabriella Lopes on 5/5/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import AVFoundation

class ChooseSongViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let model = Model.sharedInstance()
    
    let soundFiles = NSBundle.mainBundle().URLsForResourcesWithExtension("caf", subdirectory: "Ringtones")! as [NSURL]
    
    let soundNames = ["Boss calling", "Drone", "Error", "Goodnight", "Ring n roll", "Simple", "Squirrels", "Supertux", "There is no phone"]
    
    var lastSelectedIndexPath: NSIndexPath?
    
//    ///The directories where sound files are located.
//    let rootSoundDirectories: [String] = ["/Library/Ringtones", "/System/Library/Audio/UISounds/New"]
//    
//    ///Array to hold directories when we find them.
//    var directories: [String] = []
//    
//    ///Tuple to hold directories and an array of file names within.
//    var soundFiles: [NSURL] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        for directory in rootSoundDirectories
//        {
//            directories.append(directory)
//        
//        }
//        getDirectories()
//        loadSoundFiles()

    }
    
    // URLs: All of the contents of the directory (files and sub-directories).
//    func getDirectories()
//    {
//        let fileManager: NSFileManager = NSFileManager()
//        for directory in rootSoundDirectories
//        {
//            let directoryURL: NSURL = NSURL(fileURLWithPath: "\(directory)", isDirectory: true)
//            
//            do {
//                if let URLs: [NSURL] = try fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions()) {
//                    var urlIsaDirectory: ObjCBool = ObjCBool(false)
//                    for url in URLs {
//                        if fileManager.fileExistsAtPath(url.path!, isDirectory: &urlIsaDirectory)
//                        {
//                            if urlIsaDirectory
//                            {
//                                let directory: String = "\(url.relativePath!)"
//                                //let files: [String] = []
//                                //let newSoundFile: (directory: String, files: [String]) = (directory, files)
//                                directories.append("\(directory)")
//                                //soundFiles.append(newSoundFile)
//                            }
//                        }
//                    }
//                }
//            }
//            catch
//            {
//                debugPrint("\(error)")
//            }
//        }
//    }
//    
//    func loadSoundFiles()
//    {
//        for i in 0...directories.count-1
//        {
//            let fileManager: NSFileManager = NSFileManager()
//            let directoryURL: NSURL = NSURL(fileURLWithPath: directories[i], isDirectory: true)
//            
//            do {
//                if let URLs: [NSURL] = try fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions())
//                {
//                    var urlIsaDirectory: ObjCBool = ObjCBool(false)
//                    for url in URLs
//                    {
//                        if fileManager.fileExistsAtPath(url.path!, isDirectory: &urlIsaDirectory)
//                        {
//                            if !urlIsaDirectory
//                            {
//                                soundFiles.append(url.filePathURL!)
//                            }
//                        }
//                    }
//                }
//            }
//            catch
//            {
//                debugPrint("\(error)")
//            }
//        }
//    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print(soundFiles.indices)
        return soundFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath:  indexPath) as! ChooseSongTableViewCell
        cell.accessoryType = (lastSelectedIndexPath!.row == indexPath.row) ? .Checkmark : .None
        
        //let directory: String = soundFiles[indexPath.section].directory
        //let fileName: String = String(soundFiles[indexPath.row].lastPathComponent)
        let filePath = soundFiles[indexPath.row]
        print(filePath)
        
        cell.songName.text = soundNames[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row != lastSelectedIndexPath!.row
        {
            if let lastSelectedIndexPath = lastSelectedIndexPath
            {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            lastSelectedIndexPath = indexPath
    
        }
        //Play the sound
        let filePath = soundFiles[indexPath.row]
        do {
            model.audioPlayer = try AVAudioPlayer(contentsOfURL: filePath)
            model.audioPlayer.play()
        } catch {
            debugPrint("\(error)")
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
