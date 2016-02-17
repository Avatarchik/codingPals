//
//  MapViewController.swift
//  tinderClone
//
//  Created by chenglu li on 12/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // Instance of CLLocationManager
    var locationManager = CLLocationManager()
    
    // pinArray for testing if new users have been added or old has been removed
    var userPinArray = [String]()
    
    // Timer for reloading user pins
    var reloadUserTimer = NSTimer()
    
    // user info prepared for user detail controller
    var userInfo = [String:AnyObject]()
    
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var isMovingObviously = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        // set the cllocation delegate to our ViewController:
        locationManager.delegate = self
        
        // set the mapView delegate to our ViewController:
        self.mapView.delegate = self
        
        // set the location accuracy, in this case, we want the best:
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // ask for user's authority for location usage (only one time). But .requestAlwaysAuthorization() will allow permanant location usage
        locationManager.requestWhenInUseAuthorization()
        
        // Get user's location after getting permission
        locationManager.startUpdatingLocation()
        
        // Get nearby user's info
        getUserInfo()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        reloadUserTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "loadNewUser", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        reloadUserTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations.first 和 locations[0]的效果是一样的
        let userLocation: CLLocationCoordinate2D? = locations.first?.coordinate
        
        // we can also get user's lat and lon
        //        var latititude = locations[0].coordinate.latitude
        //        var longitude = locations[0].coordinate.longitude
        
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        // to test if userLocation is nil or not
        if let coordinate = userLocation {
            
            let location2D: CLLocationCoordinate2D = coordinate
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location2D, span)
            // set up the map as where I am
            
            if isMovingObviously{
                
                mapView.setRegion(region, animated: true)
            }
            
            if (coordinate.longitude - currentLocation.longitude) > abs(0.0001) || (coordinate.latitude - currentLocation.latitude) > abs(0.0001) {
                
                isMovingObviously = true
                
            }else{
                
                isMovingObviously = false
            }
            
            currentLocation = coordinate
            
            mapView.showsUserLocation = true
        
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {

            return nil
        }
        
        let reuseId = "custom"
        let annotation = annotation as! CustomPointAnnotation
        
        // Set up profile view in preparation for user profiles
        let profileView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
        profileView.layer.cornerRadius = profileView.frame.size.height/2
        profileView.layer.borderWidth = 1.0
        profileView.layer.masksToBounds = true
        profileView.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Change the UIImageView's content mode to aspect fit
        profileView.contentMode = UIViewContentMode.ScaleAspectFill
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            let btn = UIButton(type: .DetailDisclosure)
            anView!.rightCalloutAccessoryView = btn
            
            let cpa = annotation as! CustomPointAnnotation
            anView!.image = UIImage(named:cpa.imageName)
            
            if let profile = annotation.userProfile {
                
                profileView.image = profile
                anView?.leftCalloutAccessoryView = profileView
                
            }else{
                profileView.image = UIImage(named: "profile_blank")
                anView?.leftCalloutAccessoryView = profileView
            }
            
        }
        else {
            
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let customPin = view.annotation as! CustomPointAnnotation
        
        userInfo["userId"] = customPin.userObjectId
        userInfo["profile"] = customPin.userProfile
        userInfo["userName"] = customPin.title
        
        print(userInfo)
        
        performSegueWithIdentifier("userDetail", sender: self)
    }
    
    
    func getUserInfo() {
        
        let query = PFUser.query()
        
        if let location = PFUser.currentUser()?["location"]{
            
            query?.whereKey("location", nearGeoPoint: location as! PFGeoPoint, withinKilometers: 100.0)
        }
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error != nil{

            }else{
                if let objects = objects as? [PFUser]{
                    
                    for object in objects{
                        
                        if object.objectId != PFUser.currentUser()?.objectId{
                            
                            if let coordinate = object["location"] as? PFGeoPoint {
                                
                                let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                
                                let annotation = CustomPointAnnotation()
                                annotation.coordinate = coordinate
                                annotation.title = object.username
                                annotation.userObjectId = object.objectId
                                annotation.subtitle = "Click to See More!"
                                
                                if let profileFile = object["largeProfile"] as? PFFile{
                                    
                                    profileFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                        
                                        if error != nil {
                                            print("Getting profile data error:\(error)")
                                        }else{
                                            if let data = data {
                                                
                                                let profile = UIImage(data: data)
                                                
                                                annotation.userProfile = profile
                                                
                                            }
                                        }
                                    })
                                }
                                
                                self.mapView.addAnnotation(annotation)
                                self.userPinArray.append(annotation.userObjectId!)
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    
    // Timer's function: Check if new users appear or old users disappear
    func loadNewUser() {
        
        let query = PFUser.query()
        
        if let location = PFUser.currentUser()?["location"]{
            
            query?.whereKey("location", nearGeoPoint: location as! PFGeoPoint, withinKilometers: 100.0)
        }
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error != nil{
                print("Location Getting error: \(error)")
            }else{
                if let objects = objects as? [PFUser]{
                    
                    // minus one because before we have excluded current user. If we do not minus 1,
                    // they are very likely to be different
                    if objects.count == (self.userPinArray.count + 1){
                        
                        print("timer ", self.isMovingObviously)
                        
                        return
                        
                    }else{
                        var tempPinArray = [String]()
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        print("changed")
                        for object in objects{
                                
                                if let coordinate = object["location"] as? PFGeoPoint {
                                    
                                    let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                    let annotation = CustomPointAnnotation()
                                    annotation.coordinate = coordinate
                                    annotation.title = object.username
                                    annotation.userObjectId = object.objectId
                                    annotation.subtitle = "Click to See More!"
                                    
                                    if let profileFile = object["largeProfile"] as? PFFile{
                                        
                                        profileFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                            
                                            if error != nil {
                                                print("Getting profile data error:\(error)")
                                            }else{
                                                if let data = data {
                                                    
                                                    let profile = UIImage(data: data)
                                                    
                                                    annotation.userProfile = profile
                                                    
                                                }
                                            }
                                        })
                                    }
                                    
                                    
                                    self.mapView.addAnnotation(annotation)
                                    
                                    if annotation.userObjectId == (PFUser.currentUser()?.objectId)!{
                                        
                                        self.mapView.removeAnnotation(annotation)
                                    }else{
                                        tempPinArray.append(annotation.userObjectId!)
                                        self.userPinArray = tempPinArray
                                    }
                            }
                        }
                    }
                }
            }
        })
    }

    
    func configureUI() {
        
        if let navBarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0){
            let navBarAttributesDict: [String: AnyObject]? = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: navBarFont]
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDict
            navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
            backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 20)!], forState: UIControlState.Normal)
            navigationItem.backBarButtonItem = backButton
        }
        
    }
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userDetail" {
            
            (segue.destinationViewController as! MapUserDetailViewController).userInfo = userInfo
        }
    }


}
