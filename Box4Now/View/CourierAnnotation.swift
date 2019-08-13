//
//  DriverAnnotation.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 20/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import Foundation
import MapKit

class CourierAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, withKey key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
    func update(annotationPosition annotation: CourierAnnotation, withCoordinate coordinate: CLLocationCoordinate2D) {
        var location = self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        self.coordinate = location
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
    }
}
