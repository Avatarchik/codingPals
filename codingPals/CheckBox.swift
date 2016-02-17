//
//  CheckBox.swift
//  tinderClone
//
//  Created by chenglu li on 11/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    let checkedImage = UIImage(named: "CheckedCheckbox.png")
    let unCheckedImage = UIImage(named: "UncheckedCheckbox.png")
    
    var isChecked = false {
        didSet{
            if isChecked{
                self.setImage(checkedImage, forState: .Normal)
            }else{
                self.setImage(unCheckedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender:UIButton){
        if sender == self {
            if isChecked{
                isChecked = false
            }else{
                isChecked = true
            }
        }
    }
}
