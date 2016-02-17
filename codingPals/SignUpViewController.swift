//
//  SignUpViewController.swift
//  tinderClone
//
//  Created by chenglu li on 1/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class SignUpViewController: PFSignUpViewController {
    
    var backgroundImage : UIImageView!;
    var alreadySign = UIButton();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "welcome_bg"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.signUpView!.insertSubview(backgroundImage, atIndex: 0)
        
        // set our login Logo
        let logo = UILabel()
        logo.text = "CodingPals"
        logo.textColor = UIColor.lightGrayColor()
        logo.font = UIFont(name: "Helvetica Neue", size: 50)
        signUpView!.logo = logo
        
        // set our login button
        signUpView?.signUpButton?.setBackgroundImage(nil, forState: .Normal)
        signUpView?.signUpButton?.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        // set our login Logo
        alreadySign.setTitle("Already Signed Up?", forState: .Normal)
        alreadySign.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.signUpView!.insertSubview(alreadySign, atIndex: 1)
        alreadySign.addTarget(self, action: "alreadySignUp", forControlEvents: UIControlEvents.TouchUpInside)
        
        // set the modal animation to flipping!
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  signUpView!.frame.width,  signUpView!.frame.height)
        
        // position logo at top with larger frame
        signUpView!.logo!.sizeToFit()
        let logoFrame = signUpView!.logo!.frame
        signUpView!.logo!.frame = CGRectMake(logoFrame.origin.x, signUpView!.usernameField!.frame.origin.y - logoFrame.height - 16, signUpView!.frame.width,  logoFrame.height)
        
        let dismissButtonFrame = signUpView!.dismissButton!.frame
        alreadySign.frame = CGRectMake(0, signUpView!.signUpButton!.frame.origin.y + signUpView!.signUpButton!.frame.height + 16.0,  signUpView!.frame.width,  dismissButtonFrame.height)
    }
    
    func alreadySignUp(){
        print("signedUp")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            dismissViewControllerAnimated(true, completion: nil)
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
