//
//  LoginVC.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 28/11/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, Alertable {

    @IBOutlet weak var emailField: RoundedTextField!
    @IBOutlet weak var passwordField: RoundedTextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedShadowButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        view.bindToKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
    
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authBtnWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            authBtn.animateButton(shouldLoad: true, withMessage: nil)
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                let userData = ["provider": user.user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isCourier: false)
                            } else {
                                let userData = ["provider": user.user.providerID, "userIsCourier": true, "isPickupModeEnabled": false, "courierIsOnTrip": false] as [String: Any]
                                 DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isCourier: true)
                            }
                        }
                        print("Email user authenticated successfully with Firebase")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        //self.showAlert(error?.localizedDescription ?? "Unknown error")
                    
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let error = error as NSError? {
                                    guard let errorCode = AuthErrorCode(rawValue: error.code) else {
                                        self.showAlert("An unexpected error occured. Please try again.")
                                        return
                                    }
                                    switch errorCode {
                                    case .invalidEmail:
                                        self.showAlert("Email invalid. Please try again.")
                                    case .wrongPassword:
                                        self.showAlert("Whoops! That was the wrong password!")
                                    case .emailAlreadyInUse:
                                        self.showAlert("Email already in use")
                                    default:
                                        self.showAlert(error.localizedDescription as String)
                                    
                                    }
                                    
                                }
                                        self.authBtn.animateButton(shouldLoad: false, withMessage: nil)
                                        self.authBtn.setTitle("SIGN UP/LOGIN", for: .normal)
                                        self.view.endEditing(false)
                             
                            } else {
                                if let user = user {
                                    if self.segmentedControl.selectedSegmentIndex == 0 {
                                        let userData = ["provider": user.user.providerID] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isCourier: false)
                                    } else {
                                        let userData = ["provider": user.user.providerID, "userIsCourier": true,"isPickupModeEnabled": false, "courierIsOnTrip": false] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isCourier: true)
                                    }
                                }
                                print("Succesfully created a new user with Firebase")
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
}
