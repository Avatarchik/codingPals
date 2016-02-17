//
//  ContactsTableViewController.swift
//  tinderClone
//
//  Created by chenglu li on 11/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse

class ContactsTableViewController: UITableViewController {
    
    var friendRequestList = [[String:AnyObject]]()
    
    var synchronizeNameList = [String]()
    var synchronizeIdList = [String]()
    var synchronizeProfileList = [[String:AnyObject]]()
    
    @IBOutlet weak var friendRequestButton: MIBadgeButton!
    
    var getUserListTimer = NSTimer()
    
    var refreshBadgeCounter = NSTimer()
    
    var isFirstTime = true
    
    var tabBadgeCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enlarge the rowHeight of each cellView
        self.tableView.rowHeight = 60
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
            backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 20)!], forState: UIControlState.Normal)
            navigationItem.backBarButtonItem = backButton
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil{
            
            refreshFriendRequestBadge()
            
            getUserListTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "getUserList", userInfo: nil, repeats: true)
            
            refreshBadgeCounter = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshBadge", userInfo: nil, repeats: true)
            
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        friendRequestList = [[String:AnyObject]]()
        
        getUserListTimer.invalidate()
        refreshBadgeCounter.invalidate()
        
        getUserList()
        
    }
    
    override func viewDidDisappear(animated: Bool) {

        if (PFUser.currentUser()?.username == nil) {

            getUserListTimer.invalidate()
            refreshBadgeCounter.invalidate()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return synchronizeIdList.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactsTableViewCell
        
        // count starts at 1, and row starts at 0. So if they have the same amount of items, then count number should be larger than row. In this case, we would want to update the cell
        if synchronizeProfileList.count > indexPath.row{
            
//            cell.userName.text = contactList[indexPath.row]["userName"] as! String
            cell.userName.text =  synchronizeNameList[indexPath.row]
            
//             if let image = contactList[indexPath.row]["profile"] as? UIImage
            
            if let image = synchronizeProfileList[indexPath.row][synchronizeIdList[indexPath.row]] as? UIImage{
                
                cell.userProfile.image = image
                
            }
        }

        return cell
    }
    
    // Get User Data to Form the Contact Table
    func getUserList(){
        
        print("test timer")
        
        synchronizeNameList = [String]()
        synchronizeIdList = [String]()
        synchronizeProfileList = [[String:AnyObject]]()
        
        let query = PFUser.query()
        // For arrays, equal to does not mean two arrays equal two each other, but if an array contains a certain item
        
        if let currentUser = PFUser.currentUser(){
            
            query?.whereKey("accepted", equalTo: currentUser.objectId!)
            
            if let acceptedList = PFUser.currentUser()!["accepted"] {
                
                query?.whereKey("objectId", containedIn: acceptedList as! [String])
                
                query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error != nil {
                        print("contacts getting error: \(error)")
                    }else{
                        
                        if let objects = objects as? [PFUser]{
                            
                            for object in objects {
                                
                                if let userProfileFile = object["largeProfile"] as? PFFile {
                                    
                                    self.synchronizeNameList.append(object.username!)
                                    self.synchronizeIdList.append(object.objectId!)
                                    
                                    userProfileFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                        
                                        if error != nil {
                                            print("Getting profile data error:\(error)")
                                        }else{
                                            if let data = data {
                                                
                                                self.synchronizeProfileList.append([object.objectId!: UIImage(data: data)!])
                                                
                                                //                                            self.contactList.append(["userId": object.objectId!, "userName":object.username!, "profile": UIImage(data: data)!])
                                                //                                            print(self.contactList)
                                                self.tableView.reloadData()
                                                
                                            }else{
                                                
                                                self.synchronizeProfileList.append([object.objectId!: UIImage(named: "person-placeholder.jpg")!])
                                                
                                                //                                            self.contactList.append(["userId": object.objectId!, "userName":object.username!, "profile": UIImage(named: "person-placeholder.jpg")!])
                                                self.tableView.reloadData()
                                            }
                                        }
                                    })
                                    
                                }else{
                                    
                                    self.synchronizeProfileList.append([object.objectId!: UIImage(named: "person-placeholder.jpg")!])
                                    
                                    //                                self.contactList.append(["userId": object.objectId!, "userName":object.username!, "profile": UIImage(named: "person-placeholder.jpg")!])
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                })
            }
        }else{
            getUserListTimer.invalidate()
            refreshBadgeCounter.invalidate()
        }
    }
    
    
    func refreshBadge(){
        
        if self.isFirstTime{
            self.tabBadgeCounter = synchronizeIdList.count
            self.navigationController?.tabBarItem.badgeValue = nil
            self.isFirstTime = false
            
        }else{
            
            if synchronizeIdList.count > self.tabBadgeCounter{
                
                self.navigationController?.tabBarItem.badgeValue = " "
                self.tabBadgeCounter = synchronizeIdList.count
                
            }
        }
    }
    
    
    
    // Get friend Request Data
    func refreshFriendRequestBadge() {

        if let currentUser = PFUser.currentUser(){
            
            let friendRequestQuery = PFQuery(className: "FriendRequests")
            friendRequestQuery.whereKey("receiverId", equalTo: currentUser.objectId!)
            friendRequestQuery.includeKey("user")
            
            friendRequestQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error != nil {
                    print("contacts getting error: \(error)")
                }else{
                    
                    if let objects = objects {
                        
                        for object in objects {
                            
                            self.friendRequestButton.badgeString = "\(objects.count)"
                            
                            if let user = object["user"] as? PFUser{
                                
                                if let profile = user["largeProfile"] as? PFFile {
                                    
                                    profile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                        
                                        if error != nil{
                                            
                                            print("friend request profile getting error:\(error)")
                                            
                                        }else{
                                            
                                            self.friendRequestList.append(["userId":user.objectId!, "userName": user.username!, "profile": UIImage(data: data!)!])
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func friendRequestPressed(sender: AnyObject) {
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("toChat", sender: self)
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChat" {
            //注意是indexPathForSelectedRow 而不是 indexPath(s)ForSelectedRow(s)
            if let indexPath = tableView.indexPathForSelectedRow {
                
                (segue.destinationViewController as! JSQViewController).userInfo["userId"] = synchronizeIdList[indexPath.row]
                    
                (segue.destinationViewController as! JSQViewController).userInfo["userName"] = synchronizeNameList[indexPath.row]
                
                (segue.destinationViewController as! JSQViewController).userInfo["profile"] = synchronizeProfileList[indexPath.row][synchronizeIdList[indexPath.row]] as? UIImage
            }
        }else if segue.identifier == "showFriendRequest" {
            
            print(friendRequestList)
            (segue.destinationViewController as! NewFriendRequestController).friendRequestList = friendRequestList
        }
    }


}
