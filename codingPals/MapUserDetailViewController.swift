//
//  MapUserDetailViewController.swift
//  tinderClone
//
//  Created by chenglu li on 12/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse

class MapUserDetailViewController: UIViewController {
    
    @IBOutlet weak var userProfile: UIImageView!
    
    @IBOutlet weak var friendRequestButton: UIButton!
    
    var friendRequestStatus: FriendRequestStatus = FriendRequestStatus.NotKnownToEach
    
    var timer = NSTimer()
    
    var userInfo = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = userInfo["userName"] as! String
        
        
        if let profile = userInfo["profile"] as? UIImage{
            
            userProfile.image = profile
            
        }
        
        configureUI()
        
        refreshFriendRequestStatus()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "refreshFriendRequestStatus", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func friendRequestButtonPressed(sender: AnyObject) {
        
        switch friendRequestStatus{
            
            case .NotKnownToEach:
                
                    friendRequestStatus = .AlreadySentRequest
                    self.friendRequestButton.setTitle("Cancel Your Request", forState: .Normal)
                    
                    let friendRequests = PFObject(className: "FriendRequests")
                    
                    friendRequests["receiverId"] = userInfo["userId"]
                    friendRequests["senderId"] = PFUser.currentUser()?.objectId
                    let pointer = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
                    
                    friendRequests["user"] = pointer
                    
                    PFUser.currentUser()?.addUniqueObject(userInfo["userId"]!, forKey: "accepted")
                    
                    do{
                        
                        try friendRequests.save()
                        try PFUser.currentUser()?.save()
                        
                    }catch{
                        print("Send Request Error: \(error)")
                    }
                    
            
                    if let acceptedFriendList = PFUser.currentUser()!["accepted"] as? [String]{
                        
                        if acceptedFriendList.contains(userInfo["userId"] as! String){
                            
                            let userQuery = PFUser.query()
                            userQuery?.whereKey("objectId", equalTo: userInfo["userId"] as! String)
                            
                            userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if error != nil{
                                    print("check friend request status error \(error)")
                                    
                                }else{
                                    if let objects = objects{
                                        
                                        for object in objects {
                                            
                                            if let userAcceptedFriendList = object["accepted"] as? [String]{
                                                
                                                if userAcceptedFriendList.contains((PFUser.currentUser()?.objectId)!){
                                                    
                                                    self.friendRequestStatus = .AlreadyFriend
                                                }else{
                                                    
                                                    self.friendRequestStatus = .AlreadySentRequest
                                                }
                                            }else{
                                                self.friendRequestStatus = .AlreadySentRequest
                                            }
                                        }
                                    }
                                }
                                
                                switch self.friendRequestStatus{
                                    
                                case .NotKnownToEach:
                                    self.friendRequestButton.setTitle("Cancel Your Request", forState: .Normal)
                                    
                                case .AlreadySentRequest:
                                    
                                    self.friendRequestButton.setTitle("Cancel Your Request", forState: .Normal)
                                    
                                case .AlreadyFriend:
                                    self.friendRequestButton.setTitle("You are accepted!", forState: .Normal)
                                }
                            })
                        }
                    }
            
            
            case .AlreadySentRequest:
                
                friendRequestStatus = .NotKnownToEach
                self.friendRequestButton.setTitle("Send Friend Request!", forState: .Normal)
                
                let requestQuery = PFQuery(className: "FriendRequests")
                requestQuery.whereKey("senderId", equalTo: (PFUser.currentUser()?.objectId)!)
                requestQuery.whereKey("receiverId", equalTo: (userInfo["userId"])!)
                
                requestQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error != nil{
                        print("delete friend request error \(error)")
                        
                    }else{
                        if let objects = objects{
                            
                            for object in objects {
                                
                                object.deleteInBackground()
                                PFUser.currentUser()?.removeObject(self.userInfo["userId"]!, forKey: "accepted")
                                do{
                                    try PFUser.currentUser()?.save()
                                    
                                }catch{
                                    print("Cancel Request Error: \(error)")
                                }
                            }
                        }
                    }
                })

            
            case .AlreadyFriend:
//                self.friendRequestButton.setTitle("Already Friend", forState: .Normal)
                performSegueWithIdentifier("mapUserChat", sender: self)
            

        }
        
    }
    
    
    func configureUI() {
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 20)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
        
        friendRequestButton.layer.cornerRadius = 10
        
        userProfile.layer.cornerRadius = userProfile.frame.size.height/2
        userProfile.layer.borderWidth = 1.0
        userProfile.layer.masksToBounds = true
        userProfile.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    func refreshFriendRequestStatus(){
        
        if let acceptedFriendList = PFUser.currentUser()!["accepted"] as? [String]{
            
            if acceptedFriendList.contains(userInfo["userId"] as! String){
                
                print(acceptedFriendList.contains(userInfo["userId"] as! String))
                print(userInfo["userId"] as! String)
                print(acceptedFriendList)
                print(PFUser.currentUser()?.objectId)
                
                let userQuery = PFUser.query()
                userQuery?.whereKey("objectId", equalTo: userInfo["userId"] as! String)
                
                userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error != nil{
                        print("check friend request status error \(error)")
                        
                    }else{
                        if let objects = objects{
                            
                            for object in objects {
                                
                                if let userAcceptedFriendList = object["accepted"] as? [String]{
                                    
                                    if userAcceptedFriendList.contains((PFUser.currentUser()?.objectId)!){
                                        
                                        self.friendRequestStatus = .AlreadyFriend
                                    }else{
                                        
                                        self.friendRequestStatus = .AlreadySentRequest
                                    }
                                }else{
                                    self.friendRequestStatus = .AlreadySentRequest
                                }
                            }
                        }
                    }
                    
                    switch self.friendRequestStatus{
                        
                    case .NotKnownToEach:
                        self.friendRequestButton.setTitle("Send Friend Request!", forState: .Normal)
                        
                    case .AlreadySentRequest:
                        
                        self.friendRequestButton.setTitle("Cancel Your Request", forState: .Normal)
                        
                    case .AlreadyFriend:
                        self.friendRequestButton.setTitle("Already Friend! Go Chat!", forState: .Normal)
                    }
                })
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapUserChat"{
            
            (segue.destinationViewController as! JSQViewController).userInfo = userInfo
        }
    }


}
