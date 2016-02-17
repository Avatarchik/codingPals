//
//  ProfileViewController.swift
//  tinderClone
//
//  Created by chenglu li on 11/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var userProgrammingLanguage = [String]()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var areaTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }
        
        userProfile.layer.cornerRadius = userProfile.frame.size.height/2
        userProfile.layer.borderWidth = 1.0
        userProfile.layer.masksToBounds = true
        userProfile.layer.borderColor = UIColor.whiteColor().CGColor

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func jsCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "JavaScript"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }

    @IBAction func pythonCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "Python"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }
    
    @IBAction func swiftCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "Swift"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }

    
    @IBAction func htmlCssCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "HTML & CSS"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }
    
    @IBAction func rubyCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "Ruby"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }
    
    @IBAction func cSharpCheckBox(sender: AnyObject) {
        
        let button = sender as! CheckBox
        let language = "C#"
        
        if button.isChecked{
            userProgrammingLanguage = userProgrammingLanguage.filter{ $0 != language}
            print("remove", userProgrammingLanguage)
        }else{
            userProgrammingLanguage.append(language)
            print("append", userProgrammingLanguage)
        }
    }
    
    @IBAction func chooseProfile(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        print("asd")
        self.userProfile.image = image
        
    }

    @IBAction func submitIno(sender: AnyObject) {
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
