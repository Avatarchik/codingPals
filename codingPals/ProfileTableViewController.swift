//
//  ProfileTableViewController.swift
//  codingPals
//
//  Created by chenglu li on 25/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProfileSexViewDelegate, ProfileLanguageViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var sexTextLabel: UILabel!
    
    @IBOutlet weak var languageText: UILabel!
    
    // a list of strings which contain the languages of users. This will be passed to LanguageController when segue happens so that we can know which cell should have the check accessory.
    // What is more, this languageOptions will also be updated through the delegate method, if anything new were added in the language controller
    var languageOptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
            profileImageView.layer.borderWidth = 1.0
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapImage")
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - Gesture Actions
    
    func didTapImage() {
        
        // Create an instance of the class UIImagePickerController
        let imagePickerController = UIImagePickerController()
        // Assign imagePickerController's delegate to our viewController
        imagePickerController.delegate = self
        // Decide which photo app you wanna access. 1. .PhotoLibrary  2. .Camera
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        // Whether you allow user to edit the photo (actually edit here only allows users to decide which part of photo they want. It is commonly used when choosing a profile photo)
        imagePickerController.allowsEditing = true
        
        // Present the ViewController of the photo app
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapSubmitButton(sender: AnyObject) {
        
        print("submit")
    }
    
    @IBAction func didTapLogOutButton(sender: UIButton) {
        
        PFUser.logOut()
        
        performSegueWithIdentifier("needLogin", sender: self)
    }
    // MARK: - Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        profileImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func didTapOnASexOption(controller:UITableViewController, cellOption: String){
        
        sexTextLabel.text = cellOption
        sexTextLabel.sizeToFit()
    }
    
    // ProfileLanguageViewDelegate's method
    func didTapOnALanguageOption(controller:UITableViewController, cellOptions: [String]){
        
        languageText.text = ""
        languageOptions = cellOptions
        
        // Have a counter to tell if the last language option has been parsed. For the last option, we do not want to concatenate a "," at the end. But for other options other than the last one, we could want a "," to seperate them
        
        var counter = 1
        let cellOptionsLength = cellOptions.count
        
        // If cellOptions' count is 0, then it means user does not choose any language, so we will set the lable to its default value.
        if cellOptions.count == 0{
            
            languageText.text = "Programming Languages You Know"
            
        }else{
            
            for option in cellOptions{
                
                switch counter{
                    
                case 1..<cellOptionsLength:
                    languageText.text = languageText.text! + option + ", "
                default:
                    languageText.text = languageText.text! + option
                    
                }
                
                counter++
                
            }
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toSexOptionView"{
            
            let profileSexTableViewController = segue.destinationViewController as!ProfileSexTableViewController
            profileSexTableViewController.delegate = self
            profileSexTableViewController.cellAccessoryChecker.append(sexTextLabel.text!)
        
        }else if segue.identifier == "toLanguageView"{
            
            let profileLanguageTableViewController = segue.destinationViewController as!LanguagesTableViewController
            profileLanguageTableViewController.delegate = self
            profileLanguageTableViewController.selectedLanguages = languageOptions
        }
    }
}
