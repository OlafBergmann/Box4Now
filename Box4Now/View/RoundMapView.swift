//
//  RoundMapView.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 23/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit
import MapKit

class RoundMapView: MKMapView {
    
    override func awakeFromNib() {
        setupView()
    }
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 10.0
    }

}
