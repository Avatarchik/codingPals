//
//  AppDelegate.swift
//  tinderClone
//
//  Created by chenglu li on 1/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import ParseTwitterUtils
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift
import HockeySDK;


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("z2smAu5nrMnhCqjAOVxCUEXxtww8pggGdTbvw8XZ", clientKey:"zlXV6yN3GqtkiIEJVyAIb7NF4rbBQptYD1IfZWkR")
        PFTwitterUtils.initializeWithConsumerKey("Adv0j80dTma7VKdbLV0gLqMH7", consumerSecret:	"glA0USsR6gBy2PH8Kvo6r65w8TFPI7y0wkPX4jhDgAndghB7yN")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
    BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d0f1ecfa231d4016b7945a96d3338bf3")
        // Do some additional configuration if needed here
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }



}

