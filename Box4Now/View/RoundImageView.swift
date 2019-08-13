//
//  RoundImageView.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 24/11/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {

    override func awakeFromNib() {
        setupView()
    }
    
func setupView() {
    self.layer.cornerRadius = self.frame.width/2
    self.clipsToBounds = true
    }

}
