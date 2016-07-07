//
//  IntroViewController.swift
//  LocationAlarm
//
//  Created by Gabriella Lopes on 6/9/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController
{

  @IBOutlet weak var pageTitle: UILabel!
  @IBOutlet weak var pageCaption: UILabel!
  @IBOutlet weak var imReadyButton: UIButton!
  
  
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
      
        self.pageTitle.text = "Welcome to Pertô!".localized
        self.pageCaption.text = "Let's get you through the basics.".localized
        self.imReadyButton.setTitle("I'm ready!".localized, forState: .Normal)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tappedIAmReady(sender: AnyObject)
    {
        
        performSegueWithIdentifier("goToTutorial", sender: self)
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
