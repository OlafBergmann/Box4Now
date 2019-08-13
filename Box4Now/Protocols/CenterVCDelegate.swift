//
//  CenterVCDelegate.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 24/11/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit

protocol  CenterVCDelegate  {
    func toggleLeftPanel()
    func addLeftPanelViewController()
    func animateLeftPanel(shouldExpand: Bool)
    
}


