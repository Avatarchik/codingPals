//
//  ViewController.swift
//  tinderClone
//
//  Created by chenglu li on 1/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4
import ParseTwitterUtils
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit

class LogInAndSignUpViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        PFUser.logOut()
        if (PFUser.currentUser() == nil) {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton, .Facebook]
            loginViewController.emailAsUsername = true
            loginViewController.signUpController?.emailAsUsername = true
            loginViewController.signUpController?.delegate = self
            self.presentViewController(loginViewController, animated: false, completion: nil)
            
        }else{
            performSegueWithIdentifier("homePage", sender: self)
        }
    }
    
    // Do something when users did login in
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("homePage", sender: self)
        
        // FBSDKGraphRequest enables us to get an FB user's information so that users do not need to fill in their basic info when signing up.
        // For more information, go to FB SDK website ~
        if let fbGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, gender"]){
            fbGraphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if error != nil {
                    print("failed to get info")
                    
                }else{
                    
                    if let result = result{
                        
                        PFUser.currentUser()!["gender"] = result["gender"]
                        PFUser.currentUser()!["name"] = result["name"]
                        
                        do{
                            try PFUser.currentUser()?.save()
                        }catch{
                            print("Failed to save FB User Info")
                        }
                        
                        let userFBId = result["id"] as! String
                        
                        let fbLargeProfilePictureURL = "https://graph.facebook.com/\(userFBId)/picture?type=large"
                        
                        if let fbpicUrl = NSURL(string: fbLargeProfilePictureURL){
                            if let profileData = NSData(contentsOfURL: fbpicUrl){
                                
                                let imgaeFile:PFFile = PFFile(data: profileData)!
                                PFUser.currentUser()!["largeProfile"] = imgaeFile
                                
                                do{
                                    try PFUser.currentUser()?.save()
                                }catch{
                                    print("Failed to save FB User Info")
                                }
                            }
                        }
                    }
                }
            })
        }else{
            print("failed")
        }
        
        presentLoggedInAlert()
        
    }
    
    // Do something when users did sign up
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        
        print("aaaa")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        presentLoggedInAlert()
        
    }
    
    // alert controller function
    func presentLoggedInAlert() {
        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Tinder Clone", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("homePage", sender: self)
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

