//
//  HomeViewController.swift
//  tinderClone
//
//  Created by chenglu li on 3/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class HomeViewController: UIViewController,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var hintLabel: UILabel!
    
    // Variable to store query results' objectId
    var displayedUserId = ""
    
    var isCurrentUser = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: Selector("dragAction:"))
        profileImage.addGestureRecognizer(dragGesture)
        
        // Allowing user to interact with the label
        profileImage.userInteractionEnabled = true
        
        // Get user's current location
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            
            if error != nil{
                print("location getting failed:\(error!)")
            }else{
                if let geoPoint = geoPoint {
                    
                    PFUser.currentUser()?["location"] = geoPoint
                    
                    do{
                        try PFUser.currentUser()?.save()
                        
                    }catch{
                        print(error)
                    }
                }
            }
        }
        
        updateUserImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        updateUserImage()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        if (PFUser.currentUser() == nil) {
            performSegueWithIdentifier("needLogin", sender: self)
        }
    }

    @IBAction func logOut(sender: AnyObject) {
        
        PFUser.logOut()
        
        performSegueWithIdentifier("needLogin", sender: self)
    }
    
    func updateUserImage() {
        
        let query = PFUser.query()
        
        var ignoredUsers = [String]()
        
        ignoredUsers.append(PFUser.currentUser()!.objectId!)
        
        if let acceptedUsers = PFUser.currentUser()?["accepted"]{
            ignoredUsers += acceptedUsers as! Array
        }
        
        if let rejectedUsers = PFUser.currentUser()?["rejected"]{
            ignoredUsers += rejectedUsers as! Array
        }
        
        // Exclude users who have already been rejected or accepted
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        // Limit users within 10 kilometers
        if let location = PFUser.currentUser()?["location"]{
            
            query?.whereKey("location", nearGeoPoint: location as! PFGeoPoint, withinKilometers: 10.0)
        }
        
        // Limit query result to only 10
        query?.limit = 1
        
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil{
                
                print(error)
                
            }else{
                if let objects = objects{
                    print(objects)
                    if objects.count == 0 {
                        // To see if there is a match or not
                        if self.isCurrentUser{
                            self.profileImage.image = UIImage(named: "noMatch.jpg")
                            self.hintLabel.text = "Try Swiping!"
                            self.hintLabel.sizeToFit()
                            print("current")
                            // To test if it is the last match
                        }else{
                            self.profileImage.image = UIImage(named: "person-placeholder.jpg")
                            self.hintLabel.text = "That's the last one..."
                        }
                    }else{
                        
                        for object in objects{
            
                                self.hintLabel.text = "Left to Reject, Right to Talk"
                                self.isCurrentUser = false
                                self.displayedUserId = object.objectId!
                                
                                let imageFile = object["largeProfile"] as! PFFile
                                imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                    if error != nil{
                                        print(error)
                                    }else{
                                        if let data = data {
                                            self.profileImage.image = UIImage(data: data)
                                        }else{
                                            self.profileImage.image = UIImage(named: "person-placeholder.jpg")
                                        }
                                    }
                                })
                         }
                        
                    }
                }
            }
        })
    }
    
    func dragAction(gesture:UIPanGestureRecognizer){
        
        // translation is actually a set of changes in position. From one item's starting point to the point where it ends. By getting the translation of the gesture in the main view, we will be able to know how our label has been dragged.
        // The translation is a tuple made of x and y
        // For example, if translation is (-100,20), it means that our item is being dragged to a place 100 px off its original x axis, and 20 px off its y axis
        let translation = gesture.translationInView(self.view)
        
        // If we did not initialize the label outside viewDidLoad method, instead, we created the label in the ViewDIdLoad, then we would not have access to the label by referring to it. But the following line allows us to get control of the label. Because for the dragging gesture, its view is the label itself.
        // But since we created the label as a property in the class, so we do not need this. We can refer to the label whereever in the class.
        
        //        let label = gesture.view!
        
        // This allows us to see the label is being dragged, because we are chaging its center's coordinates on the fly
        profileImage.center = CGPoint(x: (self.view.bounds.width / 2) + translation.x, y: (self.view.bounds.height / 2) + translation.y)
        
        // This is going to be either negative(when dragged to the left), or positive (to the right). We need this xFromLabelCenter as a reference later to make the rotation and scaling animation
        let xFromLabelCenter = profileImage.center.x - (view.bounds.width / 2)
        
        // rotation takes a value from -2pi to 2pi. If the value is negative, then it will rotate counter-clockwise. Vice versa for a positive value. And 2pi(around 6,8) stands for 360 degrees. So value 1 is approximately 60 degrees. 4pin means our object will rotate 720 degrees, and so on.
        // The reason why we divide the xFromLabelCenter by 200 is because xFromLabelCenter tends to be more than 200, so divide it by 200 can give us a rotation around 60 degrees.
        var rotation = CGAffineTransformMakeRotation(xFromLabelCenter / 200)
        
        // The scale is for proportional scaling. Here, we are using abs to get the absolute value of xFromLabelCenter, since it could be negative. And then we are using max() to get the maximun value between 70 and xFromLabelCenter. Then we are using the maximum value to divide 70.
        // The reason is, we wanna have the effect that the further we drag, the small the item becomes. Scaling takes value from 0 to 1, with 1 being the original size. So, if we wanna make the item smaller as we drag away, we need to have a algorithm to create a smaller value as we drag. So we need to have a 分子. The bigger the maximum value is, the smaller the item scales down.
        // By using the max(), we also ensure that within the distance of 70px, the item will not be scaled down, because at this time, the maximum value is 70, and 70 / 70 equals 1, which means the original size. But once the distance is bigger than 70 px, the item will starts to shrink, as the maximum value is xFromLabelCenter, which is bigger than 70, and will continue to be even bigger. Then we will get a value smaller than 1, and become smaller as we drag.
        
        // The reason why we do not use the commented line of code is, if the user accidentally place the item to its original place, which makes xFromLabelCenter 0, then we will crash. Since 0 cannot be the 分母.
        //  let scale = min( 90 / abs(xFromLabelCenter),1)
        let scale = 70/max(abs(xFromLabelCenter), 70)
        
        // Combine the rotation and the scaling together
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        // Apply the stretch to our label
        profileImage.transform = stretch
        
        // Do something after the dragging has been ended
        if gesture.state == UIGestureRecognizerState.Ended{
            
            if profileImage.center.x < 100{
                print("Not Chosen")
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: "rejected")
                
                do{
                    try PFUser.currentUser()?.save()
                }catch{
                    print(error)
                }
            }else if profileImage.center.x > (self.view.bounds.width - 100) {
                print("Chosen!")
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: "accepted")
                
                do{
                    try PFUser.currentUser()?.save()
                }catch{
                    print(error)
                }
            }
            
            // Resize and reposition the label to its original size and position
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            profileImage.transform = stretch
            profileImage.center = CGPoint(x: (self.view.bounds.width / 2), y: (self.view.bounds.height / 2))
            
                updateUserImage()
            // add fade in animation to the image
            self.profileImage.alpha = 0
            UIView.animateWithDuration(1.0, animations: { self.profileImage.alpha = 1.0 })
        }
    }
    
    // MARK: - Delegate Method

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
