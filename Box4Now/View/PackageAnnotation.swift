//
//  PassengerAnnotation.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 22/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import Foundation
import MapKit

class PackageAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
