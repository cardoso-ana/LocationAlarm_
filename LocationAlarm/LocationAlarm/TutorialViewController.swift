//
//  ViewController.swift
//  tutorialPageViewController
//
//  Created by Gabriella Lopes on 6/2/16.
//  Copyright © 2016 Gabriella Lopes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TutorialViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    
    var pageViewController: UIPageViewController!
    var pageTitles = ["TutorialTitlePageOne".localized,"TutorialTitlePageTwo".localized]
    var pageCaptions = ["TutorialCaptionPageOne".localized,"TutorialCaptionPageTwo".localized]
    var pageVideos = ["PertoFirstVideoDoneOK","PertoSecondVideoDoneOK"]
    
    @IBOutlet weak var botaoGotIt: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
      
        self.botaoGotIt.setTitle("Got it!".localized, forState: .Normal)
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let firstPage = self.viewControllerAtIndex(0) as ContentViewController
        
        self.pageViewController.setViewControllers([firstPage], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 10, self.view.frame.width, self.view.frame.size.height - 80)
        
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func restartAction(sender: AnyObject) {
//        
//        let startVC = self.viewControllerAtIndex(0)
//        let viewControllers = NSArray(object: startVC)
//        
//        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
//        
//    }
    
    func viewControllerAtIndex(index:Int) -> ContentViewController
    {
        if index != self.pageTitles.count - 1
        {
            self.botaoGotIt.hidden = true
            
        }
        else
        {
            self.botaoGotIt.hidden = false
        }
        
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return ContentViewController()
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.videoName = self.pageVideos[index]
        vc.titleText = self.pageTitles[index]
        vc.captionText = self.pageCaptions[index]
        vc.pageIndex = index
        
        return vc
        
    }
    
    //MARK: Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if index == 0 || index==NSNotFound
        {
            
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if index == NSNotFound
        {
            return nil
        }
        
        index += 1
        
        if index == self.pageTitles.count
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
    {
        
        print("chamou a funcao da transicao")
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        
        print("did finish animating")
        
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        
        return self.pageTitles.count
        
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        
        return 0
        
    }
    
    
    @IBAction func exitTutorial(sender: AnyObject)
    {
        
        performSegueWithIdentifier("goToMainApp", sender: self)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}

