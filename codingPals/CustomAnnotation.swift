//
//  CustomAnnotation.swift
//  tinderClone
//
//  Created by chenglu li on 12/2/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String! = "customPin.png"
    var userObjectId: String?
    var userProfile: UIImage?
}