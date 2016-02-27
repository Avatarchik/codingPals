//
//  LanguagesTableViewController.swift
//  codingPals
//
//  Created by chenglu li on 25/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class LanguagesTableViewController: UITableViewController {
    
    // An array of ProgrammingLanguage class's instances
    var languages = [ProgrammingLanguage]()
    
    // selectedLanguages is used to detect if chechmark should be given to a cell. Also, it is responsible for passing its value to profile controller in the delegate method
    var selectedLanguages = [String]()
    var delegate:ProfileLanguageViewDelegate?
    
    // Initialize searchController. Set searchResultsController to nil means we will not present the search results in a different viewController
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredLanguages = [ProgrammingLanguage]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }
        
        languages = [
            ProgrammingLanguage(category: "Web", name: "HTML & CSS"),
            ProgrammingLanguage(category: "Web", name: "JavaScript"),
            ProgrammingLanguage(category: "Web", name: "Ruby"),
            ProgrammingLanguage(category: "Web", name: "jQuery"),
            ProgrammingLanguage(category: "Web", name: "BootStrap"),
            ProgrammingLanguage(category: "Mobile", name: "Java"),
            ProgrammingLanguage(category: "Mobile", name: "Swift"),
            ProgrammingLanguage(category: "Mobile", name: "Objective-C"),
            ProgrammingLanguage(category: "Mobile", name: "C#"),
            ProgrammingLanguage(category: "Mobile", name: "iOS"),
            ProgrammingLanguage(category: "Mobile", name: "Android"),
            ProgrammingLanguage(category: "Backend", name: "php"),
            ProgrammingLanguage(category: "Backend", name: "python"),
            ProgrammingLanguage(category: "Backend", name: "SQL"),
            ProgrammingLanguage(category: "Backend", name: "MongoDB")
        ]
        
        // Sort the arrays from A to Z
        languages.sortInPlace(){
            $0.name.lowercaseString < $1.name.lowercaseString
        }
        
        searchController.searchResultsUpdater = self
        // If false, background will not be dim when search is active. If true, the background will be dim
        searchController.dimsBackgroundDuringPresentation = false
        // Close search bar when we jump to a different view, even when search bar is active
        definesPresentationContext = true
        // Add searchController to tableView.tableHeaderView
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableHeaderView?.layer.borderColor = UIColor(red: 105.0/255.0, green: 215.0/255.0, blue: 189.0/255.0, alpha: 1.0).CGColor
        tableView.tableHeaderView?.layer.masksToBounds = true
        
        // Set up search scope
        searchController.searchBar.scopeButtonTitles = ["All", "Web", "Mobile", "Backend"]
        searchController.searchBar.delegate = self
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredLanguages = languages.filter {
            
            language in
            
            let categoryMatch = (scope == "All") || (language.category == scope)
            
            if searchText.isEmpty {
                return categoryMatch
            } else {
                return categoryMatch && language.name.lowercaseString.containsString(searchText.lowercaseString)
            }
            
        }
        tableView.reloadData()
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
        
        // if search bar is active and the text is not empty, then we will activate the related method so that we can see filtered results
        if searchController.active && (searchController.searchBar.text != "" || !filteredLanguages.isEmpty) {
            return filteredLanguages.count
        }
        
        return languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LanguageCell
        
        let language: ProgrammingLanguage
        
        if searchController.active && (searchController.searchBar.text != "" || !filteredLanguages.isEmpty) {
            
            language = filteredLanguages[indexPath.row]
            
        } else {
            
            language = languages[indexPath.row]
        }
        
        cell.textLabel!.text = language.name
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        cell.textLabel?.alpha = 0.75
        cell.textLabel?.tintColor = UIColor.whiteColor()
        
        // When segue happens, selectedLanguages will get its value from the ProfileController. And then we use the data to check which cell should be "checked"
        // Because we are using the same viewController to present the search results, which means we will have messy indexPath issue. E.g. For the "All" scope, the first cell of the 1st row is "Android". But in the "Web" scope, the first cell is "BootStrap". And because we are changing cell's accessory using the didSelectRowAtIndexPath method, this will give wrong accessory to a cell. If I tap on Androd in "All", then change to "Web", then bootstrap will be marked as "checked". So I need this logic to make sure cells' UIs are correctly shown
        if selectedLanguages.contains(cell.textLabel!.text!){
            cell.accessoryType = .Checkmark
            cell.hasBeenTapped = true
        }else{
            cell.hasBeenTapped = false
            cell.accessoryType = .None
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LanguageCell
        
        if !cell.hasBeenTapped{
            
            cell.hasBeenTapped = true
            cell.accessoryType = .Checkmark
            selectedLanguages.append((cell.textLabel?.text)!)
            
            
        }else{
            cell.hasBeenTapped = false
            cell.accessoryType = .None
            selectedLanguages = selectedLanguages.filter({ (language) -> Bool in
                return !(language == (cell.textLabel?.text)!)
            })
        }
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        
        delegate?.didTapOnALanguageOption(self, cellOptions: selectedLanguages)
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}

// MARK: - extension

extension LanguagesTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension LanguagesTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        
    }
    
}

