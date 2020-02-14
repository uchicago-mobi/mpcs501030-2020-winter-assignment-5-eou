//
//  Place.swift
//  Project5
//
//  Created by Hangyi Wang on 2020/2/12.
//  Copyright © 2020 Hangyi Wang. All rights reserved.
//

import Foundation
import MapKit

class Place: MKPointAnnotation {
    // Name of the place
    let name: String?
    // Description of the place
    let longDescription: String?
    
    init(name: String, longDescription: String) {
      self.name = name
      self.longDescription = longDescription
      super.init()
    }
}
