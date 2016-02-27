//
//  ProfileSexTableViewController.swift
//  codingPals
//
//  Created by chenglu li on 25/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class ProfileSexTableViewController: UITableViewController {
    
    var delegate:ProfileSexViewDelegate?
    
    var cellAccessoryChecker = [String]()
    
    let sexOptions = ["Male","Female","Alien"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }

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
        return sexOptions.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = sexOptions[indexPath.row]
        
        // Check if any of these options has been selected. If so, add the checkmark accessory to the cell. If not, nothing.
        if cellAccessoryChecker.contains((cell.textLabel?.text)!){
            
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let cellOption = cell?.textLabel?.text
        
        delegate?.didTapOnASexOption(self, cellOption: cellOption!)
        
        // Programatically click the "back" button
        navigationController?.popViewControllerAnimated(true)
        // It seems like we cannot use dismissview method here, because this will dismiss the whole navigation controller, meaning the root controller?

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section{
            
        case 0:
            return "Your Sex"
        default:
            return nil
        }
    }

}
