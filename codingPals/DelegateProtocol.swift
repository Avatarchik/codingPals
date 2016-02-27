//
//  DelegateProtocol.swift
//  tinderClone
//
//  Created by chenglu li on 13/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

protocol ContactsTableDelegate {
    
    func stopTimer(controller:ContactsTableViewController, timerToStop1: NSTimer, timerToStop2: NSTimer?)
}


protocol ProfileSexViewDelegate {
    
    func didTapOnASexOption(controller:UITableViewController, cellOption: String)
}


protocol ProfileLanguageViewDelegate {
    
    func didTapOnALanguageOption(controller:UITableViewController, cellOptions: [String])
}
