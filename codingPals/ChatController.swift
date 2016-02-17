//
//  ChatController.swift
//  tinderClone
//
//  Created by chenglu li on 11/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVKit
import AVFoundation

class JSQViewController: JSQMessagesViewController,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userInfo = [String:AnyObject]()
    var friendId: String = ""
    var friendProfile: JSQMessagesAvatarImage!
    var myProfile: JSQMessagesAvatarImage!
    
    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    
    var users = [PFUser]()
    var profileUsers = [PFUser]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var updateMessages = false
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendId = userInfo["userId"] as! String
        self.navigationItem.title = userInfo["userName"] as! String
        
        if let user = PFUser.currentUser(){
            self.senderId = user.objectId
            self.senderDisplayName = user["username"] as! String
        }else{
            let alert = UIAlertController(title: "Network Error :(", message: "It seems that you are having a connection issue, please try later", preferredStyle: .ActionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profile_blank.jpg"), diameter: 30)
        
        isLoading = false
        
        if let currentUserProfileFile = PFUser.currentUser()!["largeProfile"] as? PFFile{
            currentUserProfileFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                self.myProfile = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: data!), diameter: 30)
            })
        }else{
            self.myProfile = blankAvatarImage
        }
        
        if let friendImage = userInfo["profile"] as? UIImage{
            
            friendProfile = JSQMessagesAvatarImageFactory.avatarImageWithImage(friendImage, diameter: 30)
        }else{
            friendProfile = blankAvatarImage
        }
        
        loadMessages()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            self.sendMessageToParse("", video: video, picture: nil)
            
        }else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            self.sendMessageToParse("", video: nil, picture: image)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    

    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        
//        var video = editingInfo![UIImagePickerControllerMediaURL] as? NSURL
//        
//        print(video)
//        var picture = image
//        print(image)
//        
//        self.sendMessageToParse("", video: video, picture: picture)
//        picker.dismissViewControllerAnimated(true, completion: nil)
//        
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView!.collectionViewLayout.springinessEnabled = false
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
}


extension JSQViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
//        var user = self.users[indexPath.item]
//        if self.avatars[user.objectId!] == nil {
//            var thumbnailFile = user["largeProfile"] as? PFFile
//            thumbnailFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
//                if error == nil {
//                    self.avatars[user.objectId! as String] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
//                    self.collectionView!.reloadData()
//                }
//            })
//            return blankAvatarImage
//        } else {
//            return self.avatars[user.objectId!]
//        }
        
        let id = self.messages[indexPath.item].senderId
        if id == friendId{
            return friendProfile
        }else{
            return myProfile
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            var message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            var previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
}

extension JSQViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        self.sendMessageToParse(text,video: nil,picture: nil)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Send Media!", message: "Make your conversation more interesting!", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Take photo", style: .Default, handler: { (action) -> Void in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
        }))
        alert.addAction(UIAlertAction(title: "Choose existing photo", style: .Default, handler: { (action) -> Void in
            Camera.shouldStartPhotoLibrary(self, canEdit: false)
        }))
        alert.addAction(UIAlertAction(title: "Choose existing video", style: .Default, handler: { (action) -> Void in
            Camera.shouldStartVideoLibrary(self, canEdit: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension JSQViewController{
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            var previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
}

extension JSQViewController{
    
    // MARK: - Responding to CollectionView tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        var message = self.messages[indexPath.item]
        if message.isMediaMessage {
            
            if let mediaItem = message.media as? JSQMediaItem {
                
                if mediaItem.isKindOfClass(JSQPhotoMediaItem){
                    
                    let mediaItem = mediaItem as! JSQPhotoMediaItem
                    var image = mediaItem.image
                    
                    navigationController?.navigationBarHidden = true
                    let fullImageView = UIImageView(image: image)
                    fullImageView.backgroundColor = .blackColor()
                    fullImageView.contentMode = .ScaleAspectFit
                    fullImageView.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
                    fullImageView.addGestureRecognizer(tap)
                    
                    fullImageView.frame = CGRectMake(self.view.center.x, self.view.center.y, 0, 0)
                    self.view.addSubview(fullImageView)
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        fullImageView.frame = self.view.frame
                    })
                    
                    
                }else if mediaItem.isKindOfClass(JSQVideoMediaItem){
                    
                    let mediaItem = mediaItem as! JSQVideoMediaItem
                    
                    if let fileURL = mediaItem.fileURL{
                        
                        let player = AVPlayer(URL: fileURL)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        
                        self.presentViewController(playerViewController, animated: true) {
                            if let validPlayer = playerViewController.player {
                                validPlayer.play()
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
        self.view.endEditing(true)
    }
    
    // Tap to dismiss full screen media
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        navigationController?.navigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
}

extension JSQViewController {
    
    func sendMessageToParse(message: String, video: NSURL?, picture: UIImage?){
        
        var videoFile: PFFile!
        var pictureFile: PFFile!
        
        if let video = video {
            
            videoFile = PFFile(name: "video.mp4", data: NSFileManager.defaultManager().contentsAtPath(video.path!)!)
            
            videoFile.saveInBackgroundWithBlock({ (succeeed, error) -> Void in
                if error != nil {
                    print("Network error")
                }
            })
        }
        
        if let picture = picture {
            
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackgroundWithBlock({ (suceeded, error) -> Void in
                if error != nil {
                    print("Picture save error")
                }
            })
        }
        
        let chat = PFObject(className: "Chat")
        chat["message"] = message
        chat["senderId"] = self.senderId
        chat["receiver"] = self.senderId
        chat["friendId"] = self.friendId
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: self.senderId)
        chat["user"] = pointer
        
        if let videoFile = videoFile {
            chat["video"] = videoFile
        }
        if let pictureFile = pictureFile {
            chat["photo"] = pictureFile
        }
        
        
        chat.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("message saved")
                self.loadMessages()
                
            } else {
                // There was a problem, check error.description
                print(error)
            }
        }
        
        self.finishSendingMessage()
    }
    
    
    func loadMessages() {
        if self.isLoading == false {
            self.isLoading = true
            var lastMessage = messages.last
            
            var query = PFQuery(className: "Chat")
            query.whereKey("receiver", equalTo: self.senderId)
            query.whereKey("friendId", equalTo: self.friendId)
            
            if lastMessage != nil {
                query.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
            }
            
            query.includeKey("user")
            query.orderByDescending("createdAt")
            query.limit = 50
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in (objects as! [PFObject]!).reverse() {
                        //                        print(object)
                        self.addMessage(object)
                        self.reloadMessagesView()
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                }
                self.isLoading = false;
            })
        }
    }
    
    
    func addMessage(object: PFObject) {
        var message: JSQMessage!
        
        var user = object["user"] as! PFUser
        let senderId = object["senderId"] as! String
        let senderDisplayName = user.username
        let date = object.createdAt
        let text = object["message"] as! String
        
        var videoFile = object["video"] as? PFFile
        var pictureFile = object["photo"] as? PFFile
        
        if videoFile == nil && pictureFile == nil {
            message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text as? String)
        }
        
        if videoFile != nil {
            var mediaItem = JSQVideoMediaItem(fileURL: NSURL(string: videoFile!.url!), isReadyToPlay: true)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: senderDisplayName, date: date, media: mediaItem)
        }
        
        if pictureFile != nil {
            var mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: senderDisplayName, date: date, media: mediaItem)
            
            pictureFile!.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData!)
                    self.collectionView!.reloadData()
                }
            })
        }
        self.users.append(user)
        messages.append(message)
    }
}

