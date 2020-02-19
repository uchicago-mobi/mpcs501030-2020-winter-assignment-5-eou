//
//  PlaceMarkerView.swift
//  Project5
//
//  Created by Hangyi Wang on 2020/2/12.
//  Copyright © 2020 Hangyi Wang. All rights reserved.
//

import UIKit
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
          clusteringIdentifier = "Place"
          displayPriority = .defaultLow
          markerTintColor = .systemOrange
          glyphImage = UIImage(systemName: "heart.fill")
        }
    }
}
