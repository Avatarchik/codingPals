//
//  ContactsTableViewCell.swift
//  tinderClone
//
//  Created by chenglu li on 11/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfile: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfile.layer.cornerRadius = userProfile.frame.size.height/2
        userProfile.layer.borderWidth = 1.0
        userProfile.layer.masksToBounds = true
        userProfile.layer.borderColor = UIColor.whiteColor().CGColor

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
