//
//  Alertable.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 22/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit

protocol  Alertable {
}

extension Alertable where Self: UIViewController {
    func showAlert(_ msg: String) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}