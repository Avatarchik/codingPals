//
//  LogInViewController.swift
//  tinderClone
//
//  Created by chenglu li on 1/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//
import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController : PFLogInViewController {
    
    var backgroundImage : UIImageView!;
    var viewsToAnimate: [UIView!]!;
    var viewsFinalYPosition : [CGFloat]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our sign up view to a customed view
        self.signUpController = SignUpViewController()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "welcome_bg"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.logInView!.insertSubview(backgroundImage, atIndex: 0)
        
        // set our login Logo
        let logo = UILabel()
        logo.text = "CodingPals"
        logo.textColor = UIColor.lightGrayColor()
        logo.font = UIFont(name: "Helvetica Neue", size: 50)
        
        // set shadow for the logo
//        logo.shadowColor = UIColor.lightGrayColor()
//        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        // set our login button
        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        // set the color to green
        logInView?.logInButton?.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        // set our forget passward button
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        // set elements on the login page that we want to animate
        viewsToAnimate = [self.logInView?.usernameField, self.logInView?.passwordField, self.logInView?.logInButton, self.logInView?.passwordForgottenButton, self.logInView?.facebookButton, self.logInView?.signUpButton, self.logInView?.logo]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
        
        // position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)
        
        // resize the login button
        let logInButtonWidth: CGFloat = 300
        logInView?.logInButton?.frame = CGRectMake(((logInView?.bounds.width)! / 2) - (logInButtonWidth / 2), (logInView?.logInButton?.frame.origin.y)!, logInButtonWidth, (logInView?.logInButton?.frame.height)! - 10)
        logInView?.logInButton?.layer.cornerRadius = 5
        
        viewsFinalYPosition = [CGFloat]();
        for viewToAnimate in viewsToAnimate {
            let currentFrame = viewToAnimate.frame
            // Get the current positions for all elements so that we could repostion them later.
            viewsFinalYPosition.append(currentFrame.origin.y)
            // Set their positions to be out of screen
            viewToAnimate.frame = CGRectMake(currentFrame.origin.x, self.view.frame.height + currentFrame.origin.y, currentFrame.width, currentFrame.height)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Now we'll animate all our views back into view
        // and, using the final position we stored, we'll
        // reset them to where they should be
        if viewsFinalYPosition.count == self.viewsToAnimate.count {
            UIView.animateWithDuration(1, delay: 0.0, options: .CurveEaseInOut,  animations: { () -> Void in
                for viewToAnimate in self.viewsToAnimate {
                    let currentFrame = viewToAnimate.frame
                    //note I’m removing the y position from the viewsFinalYPosition array on each iteration of the loop - this is a little trick to let me reset the array so that the next time viewDidAppear is called it won’t re-animate everything again
                    viewToAnimate.frame = CGRectMake(currentFrame.origin.x, self.viewsFinalYPosition.removeAtIndex(0), currentFrame.width, currentFrame.height)
                }
                }, completion: nil)
        }
        
        if (PFUser.currentUser() != nil) {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
